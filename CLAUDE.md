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
- **Freeze**: `execute: freeze: auto` in `_quarto.yml` caches all chunk outputs in `_freeze/`. All code-bearing chapters are frozen (48 `.qmd` files total as of 2026-07-01; `same-data-different-estimators.qmd` has no code chunks, so it has no `_freeze/` entry by design).
- **Rare events chapter** (`rare-events.qmd`): Originally used `Zelig` package (deprecated), rewritten to use `brglm2` with `method="brglmFit"` and `type="AS_mean"`
- **TMLE chapter** (`tmle.qmd`): SuperLearner library trimmed to 7 fast algorithms (removed randomForest, gbm, gam, loess) for render performance
- **Data files**: `wage2015_subsample_inference.csv` (gwg chapter), `osic_pulmonary_fibrosis.csv` (numpyro chapter); all other data from URLs or built-in datasets
- **Python chapters**: `uplift.qmd` uses Python with `eval: false` (display only, no execution)
- **Incomplete chapters**: `numpyro.qmd` has R portion only (random effects model); Python/numpyro code not yet added
- **Known warnings**: `lmtp.qmd` and `causal-simulation.qmd` produce `:::` fenced div warnings during render — cosmetic only, output is correct

## Stata chunks: the `collectcode` + `cache` trap

Six chapters chain Stata chunks with `collectcode: true` so that later chunks can
use data built by earlier ones: `chow-test`, `mundlak-device`,
`correlated-random-effect`, `poisson-iv-fe`, `multilevel-models`, `stata-cate`.

**The failure mode.** `collectcode` accumulates a chunk's code *at execution
time*. If an earlier `collectcode` chunk is served from the knitr cache while a
later chunk re-executes, the earlier code never enters Statamarkdown's buffer, so
every command in the later chunk runs against missing data, fails, and the chunk
renders **silently blank** — and that empty result is then cached in turn. No
error appears in the render log. `mundlak-device`'s main chunk (~40 regressions)
published blank this way from 2026-07-04 to 2026-07-30 before anyone noticed.

Note the asymmetry: a **prose** edit is safe, because it leaves every chunk served
uniformly from cache. The danger is editing the **code** of one Stata chunk in a
chapter whose other Stata chunks are cached.

**Recovery.** Delete the entire `<chapter>_cache/` directory — not just the
offending chunk's entry — *and* `_freeze/<chapter>/`, then re-render so all chunks
execute in order. Clearing `_freeze/` alone does nothing: it makes Quarto
re-execute the document, but knitr still serves the cached chunks. Clearing one
chunk's cache entry alone does nothing either, because `freeze` skips execution
entirely.

**Current policy (set 2026-07-30, deliberately — please don't silently revert).**
`cache: true` has been *removed* from the Stata chunks in five of the six
chapters, because a from-scratch render costs almost nothing there and the risk is
not worth 10 seconds:

| chapter | full Stata re-render |
|---|---|
| correlated-random-effect | 6 s |
| mundlak-device | 8 s |
| chow-test | 10 s |
| poisson-iv-fe | 13 s |
| multilevel-models | 36 s |

`stata-cate` is the exception and **keeps** its cache: Stata's `cate` command does
lasso cross-fitting plus a random forest, and a full re-execution takes **335 s**,
which is too high a tax on prose edits. That chapter carries a `callout-warning`
explaining the trap and the recovery. If you ever edit one of its Stata chunks,
clear the whole cache directory.

Caches on the **R** chunks are untouched everywhere — `brms` (likert-scale-variance),
SuperLearner (tmle), grf (causal-forest-panel) and the bootstrap chapters are
minutes of compute and genuinely need them. The trap is specific to `collectcode`,
which is a Statamarkdown feature with no R equivalent here.

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
- 4 further chapters added since (frengression, partial-interference, same-data-different-estimators, tasc) — 48 total

## Review pass (2026-06-07)
Math/code audit + fixes across ~33 chapters (audit trail: ../_review/). Key corrections:
- causal-forest-panel: unit effects indexed by firm-loop index `[i]` instead of row `[k]` (both nonlinear DGPs); `pmin(X3,0)` recycled a length-4000 vector.
- gwg: `vcov=~subclass` referenced a nonexistent column (errored); `subset(female==1)` missing data arg.
- extended-twfe: `emfx()` used the wrong model object; Callaway–Sant'Anna paragraph was a wrong copy of Sun–Abraham.
- correlated-random-effect: within/FE transform algebra. g-estimation: unbalanced bracket + Bernoulli needs logit⁻¹.
- weights-ols: vacuous weight identity + control-weight sign. more-cre: probit `Pr(y=1)=Φ(...)` (error was inside the link). mediation-analysis: removed stray Stata `.4*m*x` interaction.
- power-list-experiment: clarified n is TOTAL (= 2× per-group). multilevel-models: `(1|region:year)` → `(year|region)` to match nlme. bartik-instrument: residualize (demean) Y,X,B before Rotemberg weights. lmtp: added DAG edges A1→L2, A1→Y to the DGP.
- Plus many notation/typo fixes (re78, Noah Greifer, Mahalanobis, β0 intercepts, etc.).
- conjoint-analysis NOT re-rendered: `radiant`'s plot fails on R 4.6 (known-unfixable); edits there reverted.
31/32 touched chapters re-rendered (incl all Stata chapters).

## Review pass (2026-07-30)
Targeted review of the two chapters added after the 2026-07-04 agy-review fix pass (commit d87e651) — `likert-scale-variance.qmd` (added 07-16) and `equivalence-testing.qmd` (added 07-24). Neither had been through any review. Report: `../_review3/review_20260730.md`. Everything else in the book was left alone.

**likert-scale-variance:**
- `SD_max(μ)/μ` was described as peaking at 0.75 at μ=4. 0.75 is the function's *value* there, not its maximum: maximizing `(μ-1)(7-μ)/μ²` gives derivative `μ^-3 (14-8μ)`, so the peak is at μ=7/4 with value ≈1.134. The curve is strongly left-skewed, not a symmetric hump — corrected and the asymmetry made the point.
- Added a paragraph noting the simulation *is* the ordinal MELSM's own functional form (shared cutpoints, constant latent σ), so the model is shown in its best case, and that the assumption actually at risk on real data is common thresholds across groups (differential item functioning), where `disc` and the thresholds trade off.
- Verified correct and left as-is: the Bhatia–Davis derivation and its two-point equality case; the Beta variance `(μ-1)(7-μ)/(1+φ)`; **Ellis (2025)'s finite-sample bound, re-derived from scratch** — the maximizer (⌊nc⌋ at the top, one interior point, rest at the floor) gives `(k+r²)/n - ((k+r)/n)²`, algebraically identical to `36[c(1-c) - a(1-a)/n]`; `disc = 1/σ`; and every prose number (mean-SD correlation −0.7371, continuous-bound 0.181/0.173, 14 undefined R). Two suspicions investigated and **dismissed**: the `r-diagnostic` table does *not* average its columns over different subsets (`var_max` is 0, not NA, so `na.rm` is a no-op), and the real-valued bound *is* exactly attainable by integer ratings here (for n=6 on a width-6 scale the interior point `1+6a` is always an integer).
- Edits were prose-only, so the `cache: true` chunks were untouched; cached results (0.626/0.200, pooled 0.219/0.211) verified unchanged after re-render.

**equivalence-testing:**
- **Unit trap, worth remembering generally: `TOSTER::t_TOST(eqb=)` is in RAW units; `BayesFactor::ttestBF(nullInterval=)` is in STANDARDIZED d.** The chapter handed `c(-2,2)` to both and claimed "the exact same ±2", which silently gave the Bayesian analysis a 1.77× wider bound (±2 s vs ±3.54 s at pooled SD 1.7678) and inflated the evidence ratio from ~45:1 to 131,014:1. Now converts via `delta_d <- 2 / sd_pooled` and states the trap explicitly. Verified from the printed statistic that eqb is raw: `(0.8232-2)/0.6392 = -1.841`, exactly the printed TOST Upper t.
- The block quote attributed to Nature Human Behaviour is not NHB's wording. Fetched the live NHB Registered Reports page: "equivalence" appears **zero** times, there is no absence-of-evidence passage, and NHB requires **0.95** a priori power, not the 0.9 quoted. The language is the COS Registered Reports template's desk-rejection criterion — verified verbatim at RIPS and Cambridge *Evolutionary Human Sciences*, which do specify 0.9. Re-attributed, quoted verbatim, with NHB's 0.95 noted separately.
- Simonsohn's "small telescopes" 33% is a **power level**, not a fraction of an effect size: `d_33%/d_80% = 0.543` and `d_33%/d_95% = 0.422`, stable across n. Reworded.
- Added the Welch-vs-JZS equal-variance asymmetry note (the frequentist tests use `var.equal = FALSE`; `ttestBF`'s JZS model assumes equal variances).

## Content pass (2026-07-30, later): gwg bad controls

Substantive addition to `gwg.qmd`, prompted by the observation that the chapter reported the occupation/industry-adjusted gap (7.5%) next to the unadjusted one (11.3%) with no comment, inviting the reading "occupation explains four points."

- **New section "Occupation and industry: a bad control problem"**, placed before the `ra4` chunk so the reader is warned before seeing the number. Occupation is post-treatment and is *both* a mediator (`Female -> Occupation -> Wage`) and a collider (`Female -> Occupation <- U -> Wage`, with `U` = drive, constraints, expected career continuity). Cites Cinelli/Forney/Pearl (2022) for the bad-control taxonomy, Elwert & Winship (2014) for the collider half, VanderWeele & Robinson (2014) for the CDE assumption.
- **`dagitty::paths()` verification table** rather than an assertion: conditioning on `Occupation` flips the mediation path open→closed and the collider path closed→open, printed side by side. This is the argument in two tables.
- **Reframed the 11.3% → 7.5% move** as three inseparable components (mediation, collider bias, mediator-outcome confounding), with the likely sign of the collider bias spelled out: if women entering male-dominated high-paying occupations are positively selected on `U`, the within-occupation gap is pushed *toward zero*, so part of the attenuation may be bias rather than mediation.
- **New `sensemakr` subsection inverting the bias formula.** The usual question is how strong `U` must be to drive the estimate to zero; here we ask how strong it must be to restore the *total* effect (`reduce = FALSE`). Additive specs (needed for a single treatment coefficient): total −0.1138, adjusted −0.0729, attenuation 0.0409. A confounder explaining ≈3.3% of the residual variance of gender and ≈4.3% of wages restores the total effect — versus a robustness value of 6.56% to zero the adjusted estimate. So roughly *half* the strength needed to erase the within-occupation gap suffices to explain the entire attenuation.
- Flagged two things the chapter had left implicit: the full-time/full-year sample restriction is itself a conditioning-on-a-collider step (employment is a common effect of gender and `U`), and AIPW/SuperLearner relax functional form but do nothing for a structurally uninterpretable estimand — added as a caveat to the nonparametric section, where the −7.5%/−6.7% agreement shows the two estimators recover the same quantity, not that the quantity is causal.

**Caching bug worth remembering:** `library(sensemakr)` was placed only in the cached `cde-sens` chunk. On a cache hit that `library()` call never runs, so `plot(sens)` in the following chunk dispatched to `plot.default` and the render failed with `xy.coords(): 'x' is a list`. Fixed by re-attaching in the uncached plotting chunk. General rule: any S3 method needed by an *uncached* chunk must have its package attached outside the cached chunks.

**ggdag gotcha:** `node_size` clips edges at the node boundary, so large nodes swallow the arrowheads — a DAG with `node_size = 26` renders with no arrows at all, which is silently useless for a collider argument. Use small nodes (`node_size = 9`) plus `geom_dag_text_repel(seed = ...)` for labels.

Chapter re-rendered clean.

## Deep read (2026-07-30): all 49 chapters

The derivation-focused inline pass this book never got in June. Log:
`../_review3/deepread_blog_book.md` (checkpointed per chapter). Method per the
standing convention — inline, one chapter at a time, no subagents, claims verified by
execution or re-derivation rather than by reading.

**The dominant defect class in this book is output that never appears.** Several
chapters described results the rendered page did not contain:

- `mundlak-device.qmd`: the entire main Stata chunk rendered with **no output** —
  the `collectcode` + `cache` interaction documented at the top of this file.
- `treatment-matching.qmd` and `uplift.qmd`: R code that was **broken and invisible**,
  hidden behind `eval: false`. Fixing `eval: false` chunks means running them first.
- `gwg.qmd`, `matching-part1.qmd`: results computed but never printed.
- `multilevel-models.qmd`: a cached chunk restored its objects but did **not** re-run
  its `library()` calls, so a later chunk dispatched to the wrong method.

So the check that pays here is not "does the prose sound right" but **"is the number
the prose describes actually on the page"**. Extract `<div class="cell-output...">`
blocks from the rendered HTML rather than searching the page text, which also matches
Quarto's echoed-source panel and produced several false findings in earlier passes.

**Claims that were simply wrong**, and are worth knowing as a class — confident
statements about relationships between methods:

- `causal-panel.qmd`: "DiD is a special case of synthetic control" — it is not.
- `tasc-time-aware-synthetic-control.qmd`: two ATT figures wrong (SDiD given as
  −16.1; the correct value is −15.60, and it now agrees with the other three books).
- `bartik-instrument.qmd`: the Rotemberg-weight sensitivity statement was inverted.
- `causal-forest-panel.qmd`: the promised FE-vs-OLS confounding never materialised in
  the DGP, and the displayed equation omitted a term.
- `chow-test.qmd`: a major inference gap — stacked estimation without clustering.
- `causal-mediation.qmd`: interventional-effects error (major).

**When a DGP is meant to demonstrate a problem, verify the problem is actually
present.** Two chapters here promised confounding or attenuation that their own
simulation did not generate. Simulate the claim, do not assume the DGP delivers it.
