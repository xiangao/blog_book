# Review suggestions for `blog_book`

Date: 2026-09-08  
Scope: editorial structure, methodological framing, navigation, citations, and reproducibility

## Overall assessment

`blog_book` is a strong applied notebook: technically ambitious, unusually candid about assumptions, and rich in executable examples. Its main remaining risk is that recent shortening improved readability but removed several important methodological qualifications.

## Highest-priority suggestions

### 1. Revisit the gender-wage-gap chapter's causal language

Several statements in `gwg.qmd` are stronger than the design supports:

- At line 28, the "explained" Oaxaca-Blinder component is called selection bias. It is fundamentally a descriptive composition term unless additional causal assumptions are supplied.
- At lines 127–132, the movement from -11.3% to -7.5% cannot be interpreted as showing that one-third of the adjusted gap "reflects" occupation while occupation is simultaneously acknowledged as a mediator and collider.
- At line 133, the -7.5% estimate is called a controlled direct effect. Identifying a CDE requires a specified intervention on the mediator and strong mediator-outcome exchangeability assumptions. A regression contrast conditional on observed occupation is not automatically a CDE.
- At lines 176–186, the AIPW result is described as machine-learning confirmation. AIPW changes functional-form assumptions; it does not repair post-treatment adjustment, sample selection, or an ill-defined treatment. "A similar adjusted association" would be more accurate.
- At line 32, the restriction to full-time workers deserves an explicit selection-bias caveat.

Much of this nuance existed in the archived pre-rewrite chapter. A compact two- or three-paragraph restoration would probably be enough; the entire long treatment need not return.

### 2. Fix the reproducibility boundary

An HTML-only `quarto render --to html --no-execute` succeeds for all 49 configured pages. The combined HTML/PDF render path failed during `conjoint-analysis.qmd` because `radiant.model` is unavailable, despite the chapter's `freeze: true` setting. The chapter also depends on an external spreadsheet whose host requires authentication.

Recommended changes:

- Vendor the small conjoint dataset if its license permits redistribution.
- Replace `radiant` with a maintained design package or a small self-contained implementation.
- Give every chapter a standard status callout: **executed**, **frozen**, or **display-only**.
- Add a lightweight CI job that runs the HTML no-execute build and checks internal links.
- Record dependency versions. The current render emits a warning that `glmmTMB` and TMB were built against different versions.

### 3. Turn chapter navigation back on

The book has 48 numbered chapters, but `_quarto.yml` sets the HTML TOC to `false`. Several chapters contain 2,000–4,000 words and many subsections. A right-side page TOC would materially improve navigation.

Consider also changing the global `code-fold: show` setting to collapsed code by default. Important short calls can remain visible using per-chunk overrides, while readers interested primarily in the argument would no longer have to scroll through every implementation block.

### 4. Add a central citation system

The book makes many scholarly claims but has no central bibliography or CSL configuration. References currently range from DOI links to informal author-year mentions and directions to consult package documentation for the exact source.

Add a `references.bib`, use Quarto citations such as `[@key]`, and generate references consistently. This would be the largest single improvement to the book's scholarly credibility and would make future citation maintenance much easier.

### 5. Improve the landing page for different audiences

The preface appropriately calls the collection a working notebook, but it gives readers no suggested route through 48 chapters. Add a few short reading paths, for example:

- **Foundations:** interactions -> marginal effects -> fixed/random effects -> matching
- **Modern causal estimation:** AIPW/TMLE -> double machine learning -> LMTP -> proximal methods
- **Panel and policy methods:** DiD -> synthetic control -> causal forest -> policy trees

A compact index listing each chapter's level, language, execution status, and approximate runtime would also help.

## Editorial and structural improvements

### Standardize titles and naming

Titles currently mix sentence case and title case, "Stata" and "stata," singular and plural "effect(s)," and informal and formal styles. Adopt one title convention across the book.

Specific naming changes worth considering:

- Rename `g-estimation.qmd`; its content is explicitly about the g-formula, not g-estimation.
- Replace time-sensitive titles such as "Recent causal inference tools" with titles naming the methods covered.
- Standardize terms such as "fixed effects," "random effects," "multilevel," "NumPyro," and "PolicyTree."

### Add consistent chapter endings

Thirty-five of the 49 configured pages do not have a heading named Summary, Conclusion, or Takeaways. A consistent three-part closing block would suit this book:

1. What is the estimand?
2. What assumptions identify it?
3. What should an applied researcher do?

### Copy-edit the older chapters

The openings of `causal-forest-panel.qmd`, `rare-events.qmd`, `synthetic-control.qmd`, and `npcausal-tools.qmd` are noticeably rougher than the recently rewritten chapters. They would benefit from a focused grammar and sentence-structure pass.

### Refine the part structure

"Advanced Topics" currently contains 13 heterogeneous chapters. Consider splitting it into sections such as:

- Heterogeneous Effects and Policy
- Experimental and Survey Designs
- Specialized and Computational Topics

If preserving the existing order is important, cross-links and recommended reading paths could provide most of the benefit without reorganizing the sidebar.

### Restore an important Likert-model caveat

The shortened `likert-scale-variance.qmd` says the ordinal model separates true dispersion from boundary artifacts. Its simulation does so because it is generated from the model's own functional form with common cutpoints across groups.

The chapter should state that common or appropriately modeled thresholds are an identifying assumption. If groups interpret response categories differently, threshold shifts and latent dispersion can trade off against one another. Similarly, the normalized $R$ statistic is a useful descriptive benchmark, but saying it "removes" boundary effects is stronger than the demonstration establishes.

## Repository housekeeping

The README has become an extensive audit log. Move that history to `CHANGELOG.md` or `docs/review-history.md` and keep the README focused on the book's purpose, contents, build instructions, and publication URL.

The README also says "50 chapters," while the configured book contains 49 pages: one preface plus 48 numbered chapters. More importantly, its audit history documents gender-wage-gap qualifications that the September shortening subsequently removed, so parts of the log no longer describe the published chapter.

## What is already working well

- All 49 configured pages have corresponding rendered HTML.
- The rendered book has no broken internal page, asset, or anchor links.
- The project has a clear seven-part organization, search, page navigation, source links, and a readable text measure.
- Many chapters do an unusually good job of placing code beside the estimand, assumptions, and interpretation.
- The book is transparent about frozen or display-only examples, even though that status should be standardized.

## Suggested order of work

1. Correct the causal wording in `gwg.qmd`.
2. Resolve or isolate the conjoint dependency and stabilize the full render path.
3. Add HTML page TOCs and improve code folding.
4. Move the README audit history and correct the page count.
5. Add the bibliography and reproducibility/status matrix.
6. Standardize titles, chapter endings, and older prose over a longer editorial pass.

