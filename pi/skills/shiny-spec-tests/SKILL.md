---
name: shiny-spec-tests
description: >
  Specification-driven testing for Shiny app-packages: translate user specs to
  features to functional requirements, track them in a traceability matrix,
  and express tests with BDD (Gherkin) via testthat describe()/it(). Covers
  fixtures, helpers, mocking with local_mocked_bindings(), graph snapshot
  tests with vdiffr. USE WHEN: deciding what to test, writing BDD-style
  testthat tests, setting up fixtures/mocks/snapshots for a Shiny app-package.
  DO NOT USE FOR: testServer/shinytest2 mechanics (see shiny-testing),
  debugging (see shiny-debug-logging).
---

# Specification-Driven Testing for Shiny App-Packages

Source: https://mjfrigaard.github.io/shiny-app-pkgs/ (chapters 15-16, appendices E-F)

## The specification ladder

Convert vague user needs into testable requirements in three steps:

1. **User specifications** — stakeholder goals ("deliver insight into movie ratings").
2. **Features** — user-facing capabilities ("explore data with a graph"). Written
   Gherkin-style: *As a ... / I want ... / So that ...*
3. **Functional requirements** — precise, testable behaviors per feature.
   Each feature yields several.

## Traceability matrix

Keep a lookup table tracing spec → feature → requirement → test. Store early drafts
in `scratch/` (`.Rbuildignored`). Every `Then` statement should map to at least one
expectation; every expectation maps back to a requirement. If a requirement has no
test or a test has no requirement, something is wrong.

| User spec | Feature | Functional req | Test file | Test |
|---|---|---|---|---|
| Analyze ratings | Visualization | Graph renders x/y/color from inputs | test-scatter_plot.R | initial axes snapshot |

## BDD with testthat

`describe()` = Feature (+ nested Background), `it()` = Scenario → expectations:

```r
describe(
  "Feature: Visualization
      As a film data analyst
      I want to explore variables in the movie review data
      So that I can analyze relationships.",
  code = {
    describe(
      "Background: Launching the application
          Given the app is loaded with movie review data",
      code = {
        it("Scenario: Initial graph
              Given the data contains 'Critics Score' and 'MPAA'
              When the scatter plot renders
              Then points map x='Critics Score', y='Audience Score'
              And points are colored by 'MPAA'", code = {
          # expectations here
        })
      })
})
```

- `describe()` verifies you built the **right things**; `it()` verifies you built
  **things right**. Each `it()` evaluates like `test_that()`.
- Keep 1:1 mapping between `tests/testthat/test-<name>.R` and `R/<name>.R`;
  combine multiple scenarios of one function in its file.

## Test suite layout

```
tests/testthat/
├── _snaps/                     # snapshots (md + svg/png)
├── fixtures/
│   ├── make-tidy_movies.R     # deterministic fixture builder
│   └── tidy_movies.rds        # saved fixture artifact
├── helper.R                    # shared helpers (e.g., test_logger)
├── setup-shinytest2.R
└── test-<each R file>.R
```

- Fixtures: build once, save `.rds`, load in tests — consistent state, no setup drift.
- Helpers: wrap repetitive start/end logging (`test_logger(start=, msg=)`) so test
  output explains what is being tested.
- Snapshots land in `_snaps/`; review diffs deliberately — first run records ("Adding
  new file snapshot" warning), later runs compare.

## Mocking external dependencies

Mocks emulate externals so unit tests stay fast and focused — they create the
`Given` conditions:

```r
local_mocked_bindings(
  is_installed = function(package) FALSE   # mock rlang::is_installed()
)
expect_error(check_installed("foo"))
```

Mock anything touching network, filesystems outside tempdir, package installation,
or time. Prefer `local_mocked_bindings()` (testthat 3, auto-restores).

## Graph output tests

Prefer `vdiffr::expect_doppelganger(title, fig)` over raw `expect_snapshot_file()`
for ggplot output — captures expected plot as `.svg` in `_snaps/`, compares on every run:

```r
vdiffr::expect_doppelganger(
  title = "Initial x y z axes",
  fig = scatter_plot(movies, x_var = "imdb_rating", ...) +
    ggplot2::theme_minimal()
)
```

## Comparison toolkit

`expect_equal()` uses `waldo::compare()` under the hood. Before writing a formal
test, preview differences interactively with `waldo::compare(old, new)`; use
`diffobj::diffObj()` in the IDE viewer for colorful side-by-side structure diffs.

## Layer responsibilities (recap)

| Layer | Tool | Tests |
|---|---|---|
| Unit | testthat | non-reactive utilities (`scatter_plot()`, validators) |
| Integration | `shiny::testServer()` | module return values, module-to-module passing |
| System | shinytest2 | full user journeys, one system test per feature before release |
