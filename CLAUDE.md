# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic paper repository for a Master's Project on **reliability estimation in series systems** using maximum likelihood techniques for right-censored and masked failure data. Investigates MLE performance for Weibull component lifetimes under varying masking probability, right-censoring time, and sample size. Defended Oct 13, 2023 at SIUE.

## Build Commands

The authoritative source is `index.Rmd` at repo root.

```bash
make pdf       # Bookdown PDF (output: pdfbook/)
make html      # Bookdown gitbook (output: gitbook/)
make word      # Word document (output: word/)
make latex     # arXiv LaTeX PDF (output: latex/paper.pdf)
make figures   # TikZ standalone figures to PDF
make all       # pdf + html + latex
make clean     # Remove build artifacts
```

## Running Simulations

```bash
Rscript results/5_system_samp_size/sim-n.R    # Sample size scenarios
Rscript results/5_system_prob_mask/sim-p.R    # Masking probability scenarios
Rscript results/5_system_tau/sim-tau.R        # Right-censoring scenarios
```

## Key R Dependencies

- `wei.series.md.c1.c2.c3` — companion package implementing the methodology ([GitHub](https://github.com/queelius/wei.series.md.c1.c2.c3), on CRAN)
- `md.tools`, `algebraic.mle`, `algebraic.dist` — supporting packages
- `boot` — bootstrap confidence intervals

## Architecture

- **`index.Rmd`** (root): Authoritative source document (bookdown format, ~2600 lines)
- **`_bookdown.yml`**: Bookdown config pointing to `index.Rmd`
- **`pdfbook/AlexTowellPaper.pdf`**: Canonical 40-page PDF
- **`latex/paper.tex`**: Pandoc-generated LaTeX for arXiv
- **`refs.bib`**: Bibliography
- **`results/`**: Simulation scripts and output data
  - `sim-scenario.R`: Base simulation function used by scenario-specific scripts
  - `5_system_*/`: Scenario-specific simulations (sample size, masking prob, censoring time)
- **`image/`**: TikZ figures (data generating process diagrams, etc.)
- **`extra/`**: Supplementary/exploratory Rmd files not included in the main paper
- **`pres/`**: Defense presentation (`pres.Rmd`)
