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

## Writing style

Chapters are written in a direct, conversational voice: state the question, show the
equation or example, then say what the result means. Headings are sentence case and
descriptive — the canned "The Problem" / "The Solution" / "Key Takeaways" template is
not used, and an ordinary explanation is written as prose rather than a list of bold
labels. Tightening prose must not make a claim stronger or more general than the
algebra, code or evidence supports. Chapter titles are sentence case as well.

The full convention is in `CLAUDE.md`.

## Author

Xiang Ao

## Changelog

Revision history for the book — review passes, audits, and corrections — is in
[`CHANGELOG.md`](CHANGELOG.md).

## Published at

<https://xiangao.github.io/blog_book/>
