# Makefile for Reliability Estimation in Series Systems paper
#
# Targets:
#   make pdf       - Build PDF book via bookdown (output: pdfbook/)
#   make html      - Build gitbook/HTML via bookdown (output: gitbook/)
#   make word      - Build Word document via bookdown (output: word/)
#   make latex     - Build arXiv LaTeX PDF (output: latex/paper.pdf)
#   make figures   - Build all TikZ standalone figures to PDF
#   make pres      - Build Beamer presentation (output: pres/pres.pdf)
#   make all       - Build pdf, html, latex, and pres
#   make clean     - Remove build artifacts

RSCRIPT := Rscript
SOURCE  := index.Rmd

TIKZ_SOURCES := $(wildcard image/*_standalone.tex)
TIKZ_PDFS    := $(TIKZ_SOURCES:.tex=.pdf)

.PHONY: all pdf html word latex pres figures clean help
.DEFAULT_GOAL := help

all: pdf html latex pres

pdf: $(SOURCE)
	$(RSCRIPT) -e "bookdown::render_book('$(SOURCE)', 'bookdown::pdf_book', output_dir = './pdfbook')"

html: $(SOURCE)
	$(RSCRIPT) -e "bookdown::render_book('$(SOURCE)', 'bookdown::gitbook', output_dir = './gitbook')"

word: $(SOURCE)
	$(RSCRIPT) -e "bookdown::render_book('$(SOURCE)', 'bookdown::word_document2', output_dir = './word')"

latex:
	$(MAKE) -C latex pdf

pres: pres/pres.Rmd
	cd pres && $(RSCRIPT) -e "rmarkdown::render('pres.Rmd', 'beamer_presentation')"

figures: $(TIKZ_PDFS)

image/%_standalone.pdf: image/%_standalone.tex
	cd image && pdflatex -interaction=nonstopmode $(notdir $<)

clean:
	rm -rf pdfbook/_main.* gitbook word
	rm -f image/*_standalone.pdf image/*_standalone.aux image/*_standalone.log
	$(MAKE) -C latex clean

help:
	@echo "Targets:"
	@echo "  make all       Build pdf, html, latex, and pres"
	@echo "  make pdf       Build PDF book via bookdown        -> pdfbook/"
	@echo "  make html      Build gitbook (HTML) via bookdown  -> gitbook/"
	@echo "  make word      Build Word document via bookdown   -> word/"
	@echo "  make latex     Build arXiv LaTeX PDF              -> latex/paper.pdf"
	@echo "  make pres      Build Beamer presentation          -> pres/pres.pdf"
	@echo "  make figures   Build TikZ standalone figures       -> image/*.pdf"
	@echo "  make clean     Remove build artifacts"
