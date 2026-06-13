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

> **2026-06-07:** Math/code review pass — see `CLAUDE.md` (Review pass section) for the list of corrections. Audit trail in `../_review/`.

> **2026-06-13:** Technical-audit fix pass (Codex audit in `../_technical_audit_20260613/`). Fixed energy-balancing example (balanced `race`, now `treat`); Stata IV wildcards `(hours? = union?)` → explicit lists; partial-interference IPW denominator (joint/conditional, not product of marginals); added `clusters = firm` to the panel causal forest; corrected the count-data omitted-zero "upward bias" claim (verified empirically: slope ~unbiased because the zero process is independent of x); rewrote the LMTP DGP prose to match the code and defined the stochastic regime + `folds=1` caveat; flagged the Poisson-on-rate model as a quasi/weighted workaround vs the offset model; narrowed the proximal-bridge and FE-Poisson control-function claims; corrected AIPW/IPW double-robust wording and the matching summary table; fixed the OLS-ATE covariate-weighting overgeneralization, the TMLE "binary-only" claim, the npcausal plug-in/cross-fitting discussion, g-estimation notation, spatial OLS-bias scope, uplift policy-evaluation caveat, and discrete-mediator CDE labeling. Polish: sensitivity typo, conjoint dependency note (pinned `freeze: true` since `radiant` is uninstallable), numpyro `eval:false` note, npcausal section renames, draft-language cleanups. Rendered clean (all 47 chapters).
