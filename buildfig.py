#!/usr/bin/env python

r"""Builds figures and caches the resulting PDFs.

A \buildfig LaTeX macro as defined below may be substituted for \input in 99%
of cases to result in the same behaviour but with the resulting figure cached.

    \newcommand{\buildfig}[1]{%
      \input{|"python buildfig.py #1"}%
    }

This script automatically compiles the wrapped TeX file in a 'standalone'
environment as many times as required. The resulting PDF is stored and an
\includegraphics snippet which displays the figure is printed on standard out.
Future calls will not rebuild the figure unless the figure (or any file it
mentions) changes. The full chain of dependencies is checked where possible.
"""

import sys
import os
import os.path
import shutil
import argparse
import hashlib
import contextlib
import tempfile
import logging
import subprocess

from collections import deque

CACHE_DIR = "cache"
"""The cached figures directory, relative to the current working directory."""

NO_SPIDER_FILES = (".csv", ".pdf")
"""File types not to spider."""

LATEX_TOC_FILES = ("toc", "aux", "bib")
"""The TOC files generated by the LaTeX build process. If these change after
running pdflatex, a further LaTeX compilation pass is necessary."""

LATEX_STUB = r"""
    \documentclass[12pt]{{standalone}}
    \input{{thesis-env.tex}}
    \begin{{document}}
        \input{{{}}}
    \end{{document}}
"""
"""A LaTeX document stub into which {} is substituted for the filename of a
target LaTeX file to build."""


@contextlib.contextmanager
def tempdir():
    """Context manager which creates a temporary directory."""
    tempdir = tempfile.mkdtemp()
    try:
        yield tempdir
    except:
        logging.error(
            "Exception thrown, temporary dir: {}".format(repr(tempdir)))
        raise
    shutil.rmtree(tempdir)


def _iter_all_files(base_directory="."):
    """Generate all filenames in a directory hierarchy."""
    for dirpath, dirnames, filenames in os.walk(base_directory):
        for filename in filenames:
            path = os.path.join(dirpath, filename)
            if path.startswith(".{}".format(os.sep)):
                path = path[1 + len(os.sep):]
            yield path


def _iter_dependencies(file_contents, all_files):
    """Iterate over all the files listed in all_files that are mentioned in
    file_contents."""
    for filename in all_files:
        if filename.encode("utf-8") in file_contents:
            yield filename


def _spider(filenames, all_files):
    """Generate the list of filenames depended on by the specified file."""
    # The file depends on itself
    dependencies = set()
    
    to_visit = deque(filenames)
    while to_visit:
        filename = to_visit.popleft()
        if filename in dependencies:
            continue
        dependencies.add(filename)
        
        # Skip non-spiderable files
        if os.path.splitext(filename)[1] in NO_SPIDER_FILES:
            continue
        
        with open(filename, "rb") as f:
            file_contents = f.read()
            for dependency in _iter_dependencies(file_contents, all_files):
                to_visit.append(dependency)
    
    return dependencies


def _hash_files(files, additional_data=b""):
    """Return a collective hash of a set of files and optionally a blob of
    additional data.
    """
    files = sorted(files)
    m = hashlib.md5()
    
    # Add the file list to the hash
    m.update(repr(files).encode("utf-8"))
    
    # Hash each file (and its length)
    for filename in files:
        with open(filename, "rb") as f:
            data = f.read()
            m.update(str(len(data)).encode("utf-8"))
            m.update(data)
    
    # Hash the additional data
    m.update(str(len(additional_data)).encode("utf-8"))
    m.update(additional_data)
    
    # Done!
    return m.hexdigest()


def _hash_toc_files(dirname):
    """Return the hash of the TOC files in a given directory."""
    return _hash_files(f for f in _iter_all_files(dirname)
                       if os.path.splitext(f)[1] in LATEX_TOC_FILES)


def _compile_figure(source, output):
    """Given a LaTeX source filename, compile it standalone and put the PDF at
    the specified location."""
    with tempdir() as working_dir:
        # Create a standalone LaTeX file to build the figure with
        figure_file = os.path.join(working_dir, "figure.tex")
        with open(figure_file, "w") as f:
            f.write(LATEX_STUB.format(source))
        
        # Compile the figure as many times as necessary
        last_toc_file_hash = None
        while True:
            # Stop re-compiling when the TOC files stop changing
            toc_file_hash = _hash_toc_files(working_dir)
            if last_toc_file_hash == toc_file_hash:
                break
            last_toc_file_hash = toc_file_hash
            
            # Compile...
            returncode = subprocess.call([
                "pdflatex", "-shell-escape", "-halt-on-error",
                "-output-directory", working_dir,
                figure_file],
                stdin=subprocess.DEVNULL,
                stdout=sys.stderr,
                stderr=sys.stderr)
            if returncode != 0:
                return returncode
        
        # Put the compiled PDF where it was asked for.
        output_file = os.path.join(working_dir, "figure.pdf")
        shutil.move(output_file, output)
        
        return 0


def _figure_hash(filename, all_files):
    """Get the hash of a figure and all its dependencies."""
    stub = LATEX_STUB.format(filename).encode("utf-8")
    
    dependencies = _spider(_iter_dependencies(stub, all_files), all_files)
    
    return _hash_files(dependencies, stub)


def _normalised_filename(filename, filehash):
    """Return a normalised filename for the cached built figure."""
    # Sanitise the filename
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    alphabet += alphabet.upper()
    alphabet += "0123456789"
    filename = "".join(c if c in alphabet else "_" for c in filename)
    
    return(os.path.join(CACHE_DIR, "{}_{}.pdf".format(filename, filehash)))


def main(args=None):
    # Always run script from root of project
    base_directory = os.path.dirname(sys.argv[0])
    if base_directory != "":
        os.chdir(base_directory)
    
    # Parse arguments
    parser = argparse.ArgumentParser(
        description="Build a LaTeX figure.")
    parser.add_argument(
        "figure",
        help="The filename of a tex file containing a figure to build.")
    parser.add_argument(
        "--no-includegraphics", "-n", action="store_true", default=False,
        help=r"Don't print an \includegraphics command to include the "
             r"compiled PDF.")
    args = parser.parse_args(args)
    
    # Fail if the figure does not exist
    if not os.path.isfile(args.figure):
        print(r"\PackageError{{buildfig}}"
              r"{{File not found: {}}}{{}}".format(args.figure))
        return 0
    
    # Enumeration of all files in the directory tree, used by various utilities
    all_files = set(_iter_all_files("."))
    
    # Find out if the figure has been built yet
    filehash = _figure_hash(args.figure, all_files)
    output_filename = _normalised_filename(args.figure, filehash)
    
    # Build the file if it doesn't exist yet
    if not os.path.isfile(output_filename):
        os.makedirs(os.path.dirname(output_filename), exist_ok=True)
        returncode = _compile_figure(args.figure, output_filename)
        
        # Fail if could not build
        if returncode:
            print(r"\PackageError{{buildfig}}"
                  r"{{Could not build {}}}{{See above}}".format(
                      args.figure))
            return returncode
    
    # Produce some LaTeX to display the figure
    if not args.no_includegraphics:
        print(r"\includegraphics{{{}}}".format(output_filename))
    
    return 0


if __name__=="__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(r"\PackageError{{buildfig}}"
              r"{{Script crashed}}{{{}}}".format(
                  args.figure, str(e)))
        raise
