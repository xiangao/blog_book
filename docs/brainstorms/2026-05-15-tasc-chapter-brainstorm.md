---
title: "TASC Chapter Brainstorm"
date: 2026-05-15
status: draft
replaces: same-data-different-estimators.qmd
---

## What We're Building

A blog chapter explaining why time structure matters for synthetic control,
using the TASC (Time-Aware Synthetic Control) package as the vehicle.

The chapter replaces `same-data-different-estimators.qmd`, which was judged too
light on econometric insight and too focused on data-loading tooling.

## Core Narrative

Static SC (Abadie-Diamond-Hainmueller 2010) treats pre-treatment periods as
interchangeable — it finds donor weights that minimize pre-period fit but
imposes no model on how outcomes evolve over time. If the underlying process
has serial correlation (latent AR factors, trending outcomes), static SC can
fit the pre-period by coincidence and the resulting confidence intervals are
too narrow.

TASC models the panel as a linear Gaussian state-space model:

    x_t = A * x_{t-1} + q_t,   q_t ~ N(0, Q)
    y_t = H * x_t + r_t,        r_t ~ N(0, R)

The Kalman filter/RTS smoother learns the latent factor path from the
pre-period, then extrapolates it post-treatment using only donor units. The
result is a posterior distribution over the treated unit's counterfactual
path — not a point estimate.

## Why This Matters

The payoff is honest uncertainty. Static SC gives a point estimate; TASC gives
a posterior variance that correctly reflects:
- how much the pre-period latent path was uncertain
- how that uncertainty propagates into the post-period forecast

This is the right comparison: not "which estimate is bigger" but "which
method knows what it doesn't know."

## Chapter Structure

### 1. The failure mode (simulation)
- Generate a small AR(1) panel (N=20, T=60, T0=50) where the latent factor
  follows a stable AR transition.
- Fit static SC (simplex weights on pre-period). Pre-period fit looks good.
- Plot the post-period: point estimate only, no interval.
- Show that the residuals are serially correlated — the static SC fit is
  leveraging temporal coincidence.

### 2. TASC on the same simulation
- Fit TASC (d=2 or 3 latent factors, EM convergence).
- Plot the posterior band: correctly wider as T1 grows (forecast uncertainty
  compounds over a Markov chain).
- The interval contains the truth at the nominal level.

### 3. Real application: Prop 99 (California tobacco tax, 1989)
- Classic ADH dataset, small (N=39 states, T=31 years, T0=19).
- Fits in a Quarto code block without local data dependencies (use the
  `Synth` R package or embed the matrix directly).
- Compare: static SC point estimate vs TASC posterior mean + 95% band.
- Key observation: TASC and SC give similar point estimates (they should —
  same data, similar bias), but TASC's band shows where the uncertainty
  actually lives.

### 4. Takeaway
- Static SC is a fitting procedure, not a generative model.
- TASC's generative model makes the uncertainty explicit and temporally
  coherent.
- When the outcome process has memory, model the memory.

## Key Decisions

| Decision | Choice | Reason |
|---|---|---|
| Language | Julia (TASC.jl) | Package is Julia; matches causal_econometrics_julia book |
| Dataset | Prop 99 (California tobacco) | Canonical, embeddable, well-known |
| Comparison baseline | Static SC (simplex) | Cleanest contrast; same latent factor, different model |
| Code execution | Frozen (eval: false or cache) | TASC EM is slow; don't re-run on every render |
| Confidence interval | Posterior variance from RTS smoother | TASC's native uncertainty, not permutation |

## Open Questions

- Should the simulation use `simulate_tasc()` from TASC.jl or a hand-rolled AR(1)?
  `simulate_tasc()` is cleaner but requires importing the package.
- Prop 99: use the `Synth` R package to get the data, then port to Julia matrix?
  Or embed a small CSV in the repo?
- Show `n_post` EM refinement or keep it off for simplicity?
  (Recommendation: off — the pre-EM version is easier to explain.)
- Length target: 800–1200 words + code blocks (matching existing blog style).

## What NOT to Include

- DuckDB or large-file data loading (that was the problem with the old chapter)
- The MSC estimator (separate tool, separate chapter)
- More than two estimators in the real application (keeps the comparison sharp)
