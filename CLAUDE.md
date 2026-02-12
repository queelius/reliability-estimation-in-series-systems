# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic paper repository for a Master's Project on **reliability estimation in series systems** using maximum likelihood techniques for right-censored and masked failure data. The paper investigates MLE performance for Weibull component lifetimes under varying masking probability, right-censoring time, and sample size.

## Build Commands

### Building the Paper (from `rmarkdown/` directory)

```bash
cd rmarkdown/

# Build PDF document
./build-pdf

# Build gitbook (HTML)
./build-gitbook

# Build Word document
./build-word

# Build LaTeX only
./build-tex
```

All builds use bookdown with `index.Rmd` as the main source file.

### Building Figures from LaTeX (from root directory)

```bash
./makefig.sh image/dep_model_standalone.tex
```

Compiles `.tex` to PDF and converts to PNG.

### Compiling the Main Paper LaTeX

```bash
pdflatex paper.tex
bibtex paper
pdflatex paper.tex
pdflatex paper.tex
```

The paper uses `\iftex` conditionals to support both `pdflatex` and `lualatex`.

## Running Simulations

Simulations are R scripts in `results/` that use the `wei.series.md.c1.c2.c3` package.

```bash
Rscript results/5_system_samp_size/sim-n.R    # Sample size scenarios
Rscript results/5_system_prob_mask/sim-p.R    # Masking probability scenarios
Rscript results/5_system_tau/sim-tau.R        # Right-censoring scenarios
```

## Key R Dependencies

```r
library(wei.series.md.c1.c2.c3)  # Custom package implementing the paper's methodology
library(md.tools)                 # Masked data tools
library(algebraic.mle)            # MLE utilities
library(algebraic.dist)           # Distribution utilities
library(boot)                     # Bootstrap confidence intervals
```

The companion R package is at: https://github.com/queelius/wei.series.md.c1.c2.c3

## Architecture

- **`paper.tex`**: Main compiled LaTeX paper (generated from bookdown)
- **`rmarkdown/index.Rmd`**: Primary source document (bookdown format)
- **`refs.bib`**: Bibliography
- **`results/`**: Simulation scripts and output data
  - `sim-scenario.R`: Base simulation function used by scenario-specific scripts
  - `5_system_*/`: Scenario-specific simulations (sample size, masking prob, censoring time)
- **`image/`**: TikZ figures for the paper (data generating process diagrams, etc.)
