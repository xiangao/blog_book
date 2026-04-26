# Topics on econometrics and causal inference - Quarto Book

## Overview
A Quarto book compiled from blogdown posts (2017–2025) and quarto_blog posts (2025) covering causal inference and applied econometrics methods with R, Stata, and Python code.

## Structure
- Flat file layout: all `.qmd` chapter files in root directory
- 7 parts: Regression Foundations, Marginal Effects & Fixed Effects, Treatment Effects & Matching, Panel Data & DiD, Count Data & Specialized Models, Causal Inference Methods, Advanced Topics
- `_quarto.yml` defines book structure, theme (cosmo), and execution settings
- `index.qmd` is the book preface

## Key Technical Details
- **Stata posts** use `library(Statamarkdown)` with `find_stata()` for path discovery; chunk options use `*|` (Stata comment char) instead of `#|`
- **Freeze**: `execute: freeze: auto` in `_quarto.yml` caches all chunk outputs in `_freeze/`. All 44 chapters are frozen as of 2026-03-14.
- **Rare events chapter** (`rare-events.qmd`): Originally used `Zelig` package (deprecated), rewritten to use `brglm2` with `method="brglmFit"` and `type="AS_mean"`
- **TMLE chapter** (`tmle.qmd`): SuperLearner library trimmed to 7 fast algorithms (removed randomForest, gbm, gam, loess) for render performance
- **Data files**: `wage2015_subsample_inference.csv` (gwg chapter), `osic_pulmonary_fibrosis.csv` (numpyro chapter); all other data from URLs or built-in datasets
- **Python chapters**: `uplift.qmd` uses Python with `eval: false` (display only, no execution)
- **Incomplete chapters**: `numpyro.qmd` has R portion only (random effects model); Python/numpyro code not yet added
- **Known warnings**: `lmtp.qmd` and `causal-simulation.qmd` produce `:::` fenced div warnings during render — cosmetic only, output is correct

## Compatibility Fixes Applied
- `estimate_average_effect()` → `average_treatment_effect()` (grf package rename)
- `PanelMatch()` now requires `PanelData()` constructor object
- `bind_cols()` requires unique column names (renamed data columns)
- `tibble(matrix)` → `as_tibble(matrix, .name_repair = "minimal")`
- `panelView()` → `panelview()` (lowercase)
- `cumuEff()` removed from gsynth (commented out)
- `weightit(method = "energy")` wrapped in tryCatch for OSQP solver failures

## Build
```bash
quarto render          # Full render (executes all chunks first time)
quarto preview         # Local preview with live reload
```
After initial render, `_freeze/` caches all output. Subsequent renders skip execution unless source changes.

## Source
- Original 40 chapters converted from blogdown posts in `../blog/content/post/` using `convert_posts.py`
- 4 additional chapters (more-cre, gwg, uplift, numpyro) added from `~/projects/myprojects/quarto_blog/posts/`
