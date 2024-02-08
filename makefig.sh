#!/bin/bash

# Get the filename without the extension
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

# Compile the .tex file to PDF
pdflatex "$1"

# Convert the PDF to PNG
convert -density 300 "${filename}.pdf" -quality 90 "${filename}.png"
