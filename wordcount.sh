#!/bin/bash
echo "This thesis contains \\num{$(texcount -1 -sum -inc thesis.tex)} words."
