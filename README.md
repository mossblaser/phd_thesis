PhD Thesis LaTeX source, raw result data and figures
====================================================

This repository contains just the files required to build my thesis which
includes raw results data and the scripts to process this data and build all
plots and figures. These scripts are all called as part of the LaTeX
compilation process. This repository does *not* contain the software used in
experiments. There are next to no good reasons why you should want to look at
this repository. Doing so will probably negatively affect your mental health.

**Be warned**, compiling this document is not for the faint hearted: it takes
ten minutes to build from a cold start and in the process calls scripts written
in at least four different programming languages and uses a dozen
non-standard-library packages. Many of the scripts involved are 'write only'
affairs for pragmatic reasons and only retained in place of the built outputs
"just in case". Just be thankful I never got around to setting up Pandoc...

Dependencies
------------

Almost all result plots in this document are generated from raw result data
included in `data/` with analysis and plotting performed at build time.
Likewise many figures are generated programmatically via TikZ, Python, R and
even Blender. Consequently, building this document requires quite a few things
to be installed. The version numbers given are known to work but other versions
may work.

* `texlive` 2015.38835-1
  * [`tikz-hexagon`](https://github.com/mossblaser/tikz-hexagon) `eb5a564`
* `texcount` v3.0
* `git` v2.9.0
* `Python` v3.5.1
  * `sympy` v1.0
  * `pillow` v3.1.1
  * `spinnaker_spinner` v2.4.0
* `R` v3.3.1
  * `ggplot2` v2.1.0
  * `dplyr` v0.4.2
  * `reshape2` v1.4
  * `tikzDevice` v0.10-1

For the bibliography to build correctly you'll also need my BibTeX file. This
is intentionally not included in the repository as it contains private notes
about papers I've read. Copies may be available on request. A PDF version of
the latest/final version of the thesis should be sufficient for most
purposes...

To edit some of the figures (which for various reasons are pre-built in the
repository) you may also need:

* Inkscape 0.91 r13725
* Blender 2.77

There are almost certainly a few Unix-specific things floating around and maybe
even Linux specific stuff so sorry about that... (Seriously strange person
compiling my thesis, or future me, why on earth aren't you using Linux and what
on earth are you doing compiling this document?!)

Building
--------

The thesis can be built using fairly standard PDF LaTeX incantations with the
inclusion of the `-shell-escape` option since this document calls out to many,
many scripts.

    $ pdflatex -shell-escape thesis
    $ bibtex thesis
    $ pdflatex -shell-escape thesis
    $ pdflatex -shell-escape thesis

A build from a fresh checkout of the repository will take about 10 minutes
while all the raw result data is crunched and the figures are generated.
Subsequent builds take about a minute as most of this stuff is cached in later
runs.

Implementation notes (yes, implementation...)
---------------------------------------------

(Hacks abound, here be dragons...)

The document should adhere to all the requirements of the 2014 edition of the
University of Manchester's [Presentation of Theses
Policy](http://documents.manchester.ac.uk/display.aspx?DocID=7420). This does
not use the `mu_thesis` template provided by the department which was
insufficiently flexible for my purposes...

The vast majority of the figures in this thesis are defined in
[TikZ](https://en.wikipedia.org/wiki/PGF/TikZ) and some take a fair amount of
time to compile for various (sometimes legitimate) reasons. Though TikZ
provides its own caching mechanism to avoid rebuilding every figure every time
the document is built this mechanism is occasionally buggy. Principle
complaints are that it doesn't detect changes in indirectly used files, it
hides error messages in figure builds and it also makes it very difficult to
build the figures stand-alone to enable speedier development. Consequently, a
slightly hack-y but very, very useful script `buildfig.py` is used to
facilitate figure caching.

The `buildfig.py` script takes as input a TeX file or other script and runs it,
caching the result. Subsequent runs will immediately return the cached file.
The cache is maintained based on a hash of every file directly or indirectly
referred to in the called script. In some random things in my thesis the
dependency chains go three or four layers deep so this is really, really
useful. It also means that changing the top-level style definitions for the
thesis automatically rebuilds all the figures from scratch. In practice this
tool is used to run everything from TikZ figure builds to R analysis scripts. A
few LaTeX macros defined in `thesis-env.tex` mark its use in the main document
source.

The `autofig.sh` script is a thin wrapper around `buildfig.py` which
automatically rebuilds a TikZ figure stand-alone whenever one of its source
files change and is really useful when working on a figure.

The `figures/ggplot_tikz.R` file contains a pile of R bits-and-pieces for
rendering pretty `ggplot2` figures in a style matching the document using
`tikzDevice`.  Sadly `tikzDevice` is not perfect so many figures do have some
awkward hacks (e.g. adding non-breaking spaces to figure labels to prevent them
being clipped).
