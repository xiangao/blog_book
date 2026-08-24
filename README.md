# Topics on econometrics and causal inference

A Quarto book collecting notes and tutorials on causal inference and applied econometrics, with implementations in R and Stata.

## Contents

- **Part I: Regression Foundations** — Interaction terms, Chow test, OLS weights
- **Part II: Marginal Effects & Fixed Effects** — Marginal effects, Mundlak device, correlated random effects
- **Part III: Treatment Effects & Matching** — Matching, weighting, sensitivity analysis
- **Part IV: Panel Data & DiD** — Causal forest, synthetic control, Bartik instruments, TWFE, DDDiD
- **Part V: Count Data & Specialized Models** — Poisson regression, rare events, IV in fixed effect Poisson
- **Part VI: Causal Inference Methods** — TMLE, mediation, g-estimation, policy learning, proximal CI, LMTP
- **Part VII: Advanced Topics** — Multi-level models, conjoint analysis, spatial econometrics, causal simulation

## Build

```bash
quarto render    # Render the book
quarto preview   # Preview with live reload
```

## Author

Xiang Ao

> **2026-08-15:** Simulation write-up pass across all 50 chapters (47 edited; `likert-scale-variance`, `same-data-different-estimators` and `index` already compliant). Every chunk now has prose before it saying what it does and — for simulated data — the complete DGP (sample size, every distribution, the treatment and outcome equations, the true parameter), and prose after it saying what the output shows. Prose only; no DGP, seed or estimator changed. **One real bug found and fixed:** `lmtp.qmd` was suffering the R analogue of the documented `collectcode` cache trap — its DGP chunk had been re-run in June after gaining a `0.5*A_1` term while the regression chunk below kept a May cached result, so the chapter said `Y` depends on `A_1` with coefficient 0.5 and then printed that coefficient as −0.006. Clearing `lmtp_cache/` and `_freeze/lmtp/` restored it to 0.494. **One correction:** the `sensitivity-analysis` IV section claimed a confounder as strong as `black` or `smsa` could not explain away the effect; its own bounds table gives adjusted intervals of [−0.021, 0.402] and [−0.019, 0.396], both containing zero (re-ran the package to confirm before editing). Two reproducibility problems flagged rather than patched: `policytree` sets no seed, and `frengression`'s torch training is not fixed by `set.seed()`. `conjoint-analysis` still cannot be re-rendered here (`radiant` uninstallable), so its published HTML lags its source. Full itemisation in `CLAUDE.md`.

> **2026-06-07:** Math/code review pass — see `CLAUDE.md` (Review pass section) for the list of corrections. Audit trail in `../_review/`.

> **2026-06-13:** Technical-audit fix pass (Codex audit in `../_technical_audit_20260613/`). Fixed energy-balancing example (balanced `race`, now `treat`); Stata IV wildcards `(hours? = union?)` → explicit lists; partial-interference IPW denominator (joint/conditional, not product of marginals); added `clusters = firm` to the panel causal forest; corrected the count-data omitted-zero "upward bias" claim (verified empirically: slope ~unbiased because the zero process is independent of x); rewrote the LMTP DGP prose to match the code and defined the stochastic regime + `folds=1` caveat; flagged the Poisson-on-rate model as a quasi/weighted workaround vs the offset model; narrowed the proximal-bridge and FE-Poisson control-function claims; corrected AIPW/IPW double-robust wording and the matching summary table; fixed the OLS-ATE covariate-weighting overgeneralization, the TMLE "binary-only" claim, the npcausal plug-in/cross-fitting discussion, g-estimation notation, spatial OLS-bias scope, uplift policy-evaluation caveat, and discrete-mediator CDE labeling. Polish: sensitivity typo, conjoint dependency note (pinned `freeze: true` since `radiant` is uninstallable), numpyro `eval:false` note, npcausal section renames, draft-language cleanups. Rendered clean (all 47 chapters).

> **2026-07-30:** Review of the two chapters added since the previous pass (`likert-scale-variance`, `equivalence-testing`); report in `../_review3/review_20260730.md`. Corrected the peak of the SD/mean curve (≈1.13 at μ=7/4, not 0.75 at μ=4 — 0.75 is its value there, not its maximum). In the equivalence chapter, fixed a unit mismatch that had gone unnoticed: `TOSTER`'s bound is in raw units while `BayesFactor`'s `nullInterval` is in standardized *d*, so the "same ±2" comparison was really using a 1.77× wider Bayesian bound and reporting ~131,000:1 evidence instead of ~45:1. Also re-attributed a block quote to the Center for Open Science Registered Reports template (the Nature Human Behaviour guidelines contain none of that language and require 0.95 power, not 0.9), and corrected the "small telescopes" bound from a fraction of an effect size to a 33% power level. Added a caveat that the Likert simulation is the ordinal model's own functional form, so common thresholds across groups is the assumption really at stake.

> **2026-07-30 (later):** `gwg.qmd` — added a "bad control" treatment of the occupation/industry adjustment, which the chapter previously reported without comment. New DAG showing occupation as simultaneously a mediator of the gender–wage path and a collider on `Female -> Occupation <- U -> Wage`, plus a `dagitty::paths()` table that verifies the flip mechanically (conditioning closes the mediation path and opens the collider path). Reframed the 11.3% → 7.5% move as three inseparable components (mediation, collider bias, mediator–outcome confounding) rather than "occupation explains four points", and noted the likely sign: positive selection of women into male-dominated occupations biases the within-occupation gap toward zero. Added a `sensemakr` sensitivity section inverting the bias formula to ask how strong *U* must be to restore the total effect — answer ≈3% of the residual variance of gender and ≈4% of wages, about half the 6.6% robustness value that would zero the adjusted estimate. Also flagged that the full-time/full-year sample restriction is itself a collider conditioning step, and that AIPW/SuperLearner fixes functional form but not the estimand. One caching bug fixed: `library(sensemakr)` lived only in a cached chunk, so on a cache hit `plot(sens)` dispatched to `plot.default` and the render died.

> **2026-07-30 (deep read):** Full-depth pass over all 49 chapters — the
> derivation-focused inline review this book had not previously had. Log:
> `../_review3/deepread_blog_book.md`. The dominant defect class here was **results
> the rendered page did not actually contain**: `mundlak-device`'s main Stata chunk
> produced no output at all (a `collectcode` + `cache` interaction, now documented in
> `CLAUDE.md`), `treatment-matching` and `uplift` hid broken R code behind
> `eval: false`, `gwg` and `matching-part1` computed results they never printed, and a
> cached chunk in `multilevel-models` restored its objects without re-running its
> `library()` calls. Also corrected several confident claims about how methods relate:
> "DiD is a special case of synthetic control" (it is not), an inverted Rotemberg
> sensitivity statement in `bartik-instrument`, two wrong ATT figures in
> `tasc-time-aware-synthetic-control` (SDiD is −15.60, not −16.1, and now agrees with
> the other three books), an interventional-effects error in `causal-mediation`, and an
> unclustered stacked estimation in `chow-test`. Two chapters promised confounding
> their own DGP did not generate.

> **2026-07-30 (estimand pass):** `gwg.qmd` — follow-up to the bad-control entry above, correcting an error it introduced and adding the distributional axis the chapter never had. (1) The previous entry called −11.3% "the total-effect estimate." That was wrong: education, potential experience and region are all downstream of sex, so `reg3` is already a controlled direct effect. Since nothing causes sex, the valid adjustment set is essentially empty and every model sits on a **CDE ladder** — total effect −3.8% (nothing held fixed), −11.3% (education/experience/region), −7.5% (+ occupation/industry) — now tabulated as such. (2) Added a composition table explaining why adjustment *widens* the gap here: women in this extract are more educated (17.5% advanced degrees vs 10.7%) while experience is identical, so holding education fixed removes their compositional advantage. (3) New subsection separating **selection from confounding**: under exogeneity of sex the raw difference *is* the total effect, and the only threat to it is the full-time/full-year sample restriction (a collider), signable here as positive selection of women into employment — so −3.8% likely *understates* the gap, matching Olivetti & Petrongolo (2008). (4) Gave the "maybe men and women differ innately" objection a precise form: such a trait is a mediator, not a confounder, and controlling for education *induces* the sex–ability association it's meant to remove, since education is a collider between them. (5) New **"Beyond the mean"** section: direct unconditional quantile gaps with 2000-rep bootstrap (0% at τ=0.10 rising to −6.7% at τ=0.75/0.90 — a glass ceiling) alongside RIF regressions (Firpo–Fortin–Lemieux 2009), with the estimand distinction spelled out — a RIF coefficient on a binary regressor is the effect of marginally raising the *share* female, **not** the male–female quantile gap, which is why the two panels disagree at every τ. Also documents that the exact zeros and non-monotonicity in the direct table are wage heaping.

> **2026-07-30 (second DAG):** `gwg.qmd` — new subsection "Two treatments, two adjustment sets," formalising the objection that if schooling and experience are taken as simply given, controlling for them is obviously right. It is: **"bad control" is a property of the triple (variable, treatment, timing), not of the variable.** Re-dating the treatment from *sex at conception* to *perceived sex at the hiring decision* (Greiner & Rubin 2011) reclassifies education from post-treatment mediator to pre-treatment covariate. Second DAG plus `isAdjustmentSet()` / `adjustmentSets()` output gives a sharper verdict than the verbal argument: adjusting for nothing is **invalid** (sex at birth confounds via the education channel, so the objection is half-right and the earlier bad-control verdict was conditional on the other estimand); adjusting for education is **also invalid** (it closes that backdoor but opens `Perceived <- SexBirth -> Educ <- A -> Wage`); and the unique minimal sufficient set is `{SexBirth}`, which **has no overlap** — sex at birth determines perceived sex, so positivity fails outright. The decision-stage estimand is therefore *not identified observationally under any conditioning strategy*, a structural result rather than a data limitation, and it says exactly what a design must do: sever `SexBirth -> Perceived` by randomising the signal, after which no adjustment is needed at all (why audit studies carry no controls; Goldin & Rouse 2000 as the limiting case, same musician with and without the screen). Adds the informal bracketing that follows from the two biases having opposite signs — the quantity of interest plausibly lies *between* −3.8% and −11.3% — flagged as not a formal bound. Closes with the normative point that no graph settles: conditioning on human capital accepts whatever produced it as baseline, right for disparate treatment, wrong for disparate impact.

> **2026-07-30 (constitutive critique):** `gwg.qmd` — new closing section "What is any of this measuring?" bringing in Hu & Kohler-Hausmann's philosophical objection to the whole good-control/bad-control procedure the chapter had just spent three sections on. The **causal/constitutive distinction**: many features attributed to sex are not downstream effects but constitutive of sex as a social status (caregiving norms, being read as a plausible authority figure), so there is no modular intervention available — "flip gender, hold education fixed" does not describe a possible state of affairs. Stated flatly as a *kind* difference from the rest of the chapter: mediator, collider, selection and positivity problems are **epistemic** (quantity exists, cannot reach it, design remedy available); the constitutive objection is **semantic** (the description picks out nothing, so no design helps). Includes the point that a DAG's cuttable arrows already encode the assumption at issue, so drawing one takes a side. Also covers Hu & Kohler-Hausmann (2024) on why re-dating the treatment to *perceived* sex does not escape it — race/sex perception is co-constituted with perception of other decision-relevant features, so "identical file, different perceived sex" holds fixed the file's significance while varying the thing that determines it (the prior-arrests example). Three replies given at full strength, including the strongest one: the *signal* is modular even if the category is not, which protects correspondence studies specifically. Closes with what survives in the chapter's own numbers — 3.8%, 11.3%/7.5%, the quantile gradient and the sensitivity statement are all safe; only "the effect of being a woman net of everything legitimate" is ill-defined, and the identification route and the constitutive route condemn that one number independently. Added `{#sec-two-treatments}` so the forward pointer resolves.

> **2026-07-30 (selection DAG):** `gwg.qmd` — replaced the ASCII sketch in the selection subsection with a real figure and a `dagitty` check. The new DAG uses the **boxed-node convention** for a variable the sample is conditioned on, which is the point being taught: the box on `Employed` is drawn by the sampling frame, not by a modelling choice — nobody typed `+ employed` into a regression, the extract simply contains only full-year full-time workers. A sample definition *is* a conditioning statement, and most applied DAGs omit the selection node entirely, which makes the graph look identified when it is not. The check declares `Employed [selected]` (a different claim from conditioning on an ordinary covariate) and returns **0 valid adjustment sets**, with `isAdjustmentSet` FALSE for both `{}` and `{Educ}`, plus the paths table showing `SexBirth -> Employed <- U -> Wage` open. Text now contrasts this explicitly with the occupation collider earlier in the chapter: there the collider opened because we *chose* to add a control, so declining was a fix; here the box precedes any modelling decision, so the remedy must attack the box (data on non-workers — Lee 2009 bounds, Neal 2004, Olivetti & Petrongolo 2008) rather than the covariate list. Chapter now carries three DAGs: occupation as mediator-and-collider, treatment re-dated to perceived sex, and sample selection.

> **2026-08-12:** Prose tightening pass across 25 chapters — removed informal patterns, compressed wordy openings, switched to "we" voice, tightened explanations into shorter paratactic prose (189 insertions, 467 deletions). No code or results changes.

> **2026-07-30 (selection simulation):** `gwg.qmd` — put numbers on the selection argument, which had been entirely graph-theoretic. Because the non-workers are absent from the extract by construction, the section now simulates a population where the truth is known ($\tau=-0.10$), applies the selection, and reports what survives: the naive selected-sample estimate comes out at **−0.039, wrong by a factor of about 2.5** and attenuated toward zero exactly as the graph predicted (mean $U$ among employed women +0.33 against +0.21 for men). Crucially it also shows that **balancing does not help**: reweighting the sex ratio to exactly 50/50 leaves the estimate unchanged to four decimals, and randomly discarding men until the counts match leaves it unchanged too — stated as the general rule that no random sampling operation can remove a bias, since bias is a property of a distribution and random sampling preserves distributions. Only inverse-probability-of-selection weighting recovers the truth, and it needs $U$. Second chunk adds **Lee (2009) bounds** across five degrees of differential selection: the bounds cover the truth in every row, but width scales almost proportionally with the trim fraction $q$, and the effect can only be signed once employment rates differ by a couple of points — at a 19-point gap the interval is [−0.34, +0.26] and contains zero. Text draws the inversion: the naive estimate degrades in lockstep with the widening, so Lee bounds are tight exactly when unnecessary and wide exactly when needed, which makes their value here diagnostic rather than inferential. Caveats stated: monotonicity is individual-level, the target becomes the always-employed subgroup, and the procedure needs both selection rates so it cannot be run on this extract at all — real US rates imply $q \approx 0.2$, so the honest conclusion from doing it properly is an interval containing zero.

> **2026-08-24:** Handwritten-markup pass, partial. The annotated copy covers only
> chapters 1, 3, 4, 6 and 7 and stops mid-chapter-7 (15 marked pages out of 578),
> so everything from chapter 8 onward is still unreviewed.
>
> One genuine bug: chapter 3 printed the Stata error `already preserved / r(621)`
> five times, because a `preserve` with no matching `restore` sat in a chunk that
> every later chunk replays under `collectcode`. Two chapters called `marginsplot`
> and then discussed a plot that was never exported into the book; both now export
> and include the figure.
>
> On content, chapter 3 gains step-by-step walk-throughs of its reshape, `expand`
> and split-instrument constructions, plus a closing paragraph naming the single
> idea behind all of them — a Chow test needs the covariance between two
> coefficients, which separate regressions never produce. Chapter 4's citation is
> completed to Hazlett and Shinkre (2024), and an over-claim is corrected: its
> worked example has a constant treatment effect, so it cannot demonstrate the
> weighting problem it was said to demonstrate. A new section supplies a discrete
> design where the problem does bite — OLS returns 2.08 where the ATE is 2.80,
> matching Angrist's variance-weighted formula to sampling noise, while
> g-computation and Lin's interaction estimator both recover the ATE. Chapter 6
> gains the summary it lacked, and chapter 7 now answers directly whether the
> between-within model is just the Mundlak device.
>
> It is, and the chapter now derives it rather than asserting it: the two designs
> are related by an invertible linear map, so they span the same column space and
> agree on the fit, the likelihood, the variance components and the GLS weight,
> differing only in coordinates. The separate result that the within coefficient
> equals the fixed-effect estimate is proved from the fact that the within
> deviation has zero mean inside every unit, which makes it orthogonal to
> everything group-invariant and leaves it untouched by quasi-demeaning — so the
> GLS weight drops out of the algebra entirely, and the identity holds for random
> effects, pooled OLS and fixed effects alike. A chunk checks all eight
> identities on the chapter's own data; every one is zero to machine precision.
> The section also says why both parameterisations survive when the fit is the
> same — they print different parameters with non-interchangeable standard
> errors, only one makes the Hausman test a single line, and only one leaves the
> within component available for a random slope — and where the equivalence
> stops, since the fixed-effect identity is a linear-model result that does not
> carry over to logit or Poisson mixed models.
