#!/bin/bash
# Automatically compile the named figure when it or its dependencies change,
# copying the output to the specified filename.
#
#   ./autofig.sh figures/figure-name.tex /tmp/out.pdf

figure="$1"
output="$2"

while sleep 0.1; do
	python buildfig.py "$figure" -o "$output"
	inotifywait -e modify -e close_write -e move -e create -e delete $(python buildfig.py "$figure" -d);
done
