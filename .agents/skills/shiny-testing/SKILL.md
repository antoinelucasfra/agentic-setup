---
name: shiny-testing
description: >
  Three-layer testing strategy for Shiny apps: unit tests with testthat,
  server reactivity tests with shiny::testServer(), and E2E browser tests
  with shinytest2. Includes covr coverage reporting and CI integration.
  USE FOR: writing Shiny tests, setting up test coverage, adding testthat tests,
  testing reactive logic, shinytest2 snapshot tests, checking code coverage,
  test scaffolding for golem modules.
  DO NOT USE FOR: non-Shiny R packages (use standard testthat workflow instead).
---

# Shiny Testing Skill (`#shiny-testing`)
> **Project standard — format & lint:** Format R with `air` and lint with `jarl`; both run via pre-commit (`air-format`, `jarl-check`). Checks/tests stay on `devtools::check()` / `testthat`.

## The Three Testing Layers

### Layer 1: Unit Tests with `testthat` (always start here)

Test **pure functions** in `fct_*.R` and `utils_*.R` — no Shiny context needed.
These are the fastest, most reliable tests. Maximize coverage here.

```r
# tests/testthat/test-fct_data.R
test_that("clean_names removes special characters", {
  expect_equal(clean_names("Hello World!"), "hello_world")
  expect_equal(clean_names(""), "")
  expect_error(clean_names(NULL))
})

test_that("format_pct rounds to 1 decimal and adds %", {
  expect_equal(format_pct(0.1234), "12.3%")
  expect_equal(format_pct(1), "100.0%")
})
```

**Setup:**
```r
usethis::use_testthat()
usethis::use_test("fct_data")  # creates tests/testthat/test-fct_data.R
```

### Layer 2: Server Reactivity Tests with `shiny::testServer()`

Test **reactive logic inside a module server** without a browser.
Use for testing input/output/reactive chains in isolation.

```r
# tests/testthat/test-mod_filter.R
test_that("mod_filter_server filters data correctly", {
  shiny::testServer(mod_filter_server, args = list(
    data = shiny::reactive(tibble::tibble(x = 1:10, group = rep(c("A","B"), 5)))
  ), {
    session$setInputs(selected_group = "A")
    expect_equal(nrow(filtered_data()), 5)
    expect_true(all(filtered_data()$group == "A"))
  })
})
```

### Layer 3: End-to-End Tests with `shinytest2`

Test the **full app in a real browser** via Chromium. Use for regression snapshots
and verifying user flows. Keep these tests focused and minimal.

```r
# tests/testthat/test-app.R
library(shinytest2)

test_that("app loads and shows main panel", {
  app <- AppDriver$new(app_dir = ".", name = "main-flow")
  
  app$set_inputs(filter_year = 2023)
  app$click("btn_apply")
  app$expect_values()      # snapshot: inputs + outputs + exports
  app$expect_screenshot()  # visual snapshot
  
  app$stop()
})
```

**Recording tests interactively:**
```r
shinytest2::record_test(".")  # opens browser with test recorder
# Clean up the generated test — remove redundant waits and add assertions
```

## File Naming Conventions

| App file | Test file |
|----------|-----------|
| `R/fct_data.R` | `tests/testthat/test-fct_data.R` |
| `R/utils_format.R` | `tests/testthat/test-utils_format.R` |
| `R/mod_filter.R` | `tests/testthat/test-mod_filter.R` |
| Full app | `tests/testthat/test-app.R` (shinytest2) |

## Robust Test Selectors (avoid brittle tests)

Add `data-testid` HTML attributes to important UI elements:

```r
# In your UI
shiny::actionButton("btn_apply", "Apply", `data-testid` = "apply-button")
shiny::textOutput("result_summary") |> 
  htmltools::tagAppendAttributes(`data-testid` = "result-summary")
```

Reference them in shinytest2:
```r
app$click(selector = "[data-testid='apply-button']")
app$get_text(selector = "[data-testid='result-summary']")
```

> Prefer `data-testid` selectors over raw input IDs — they survive refactoring.

## golem Integration

```r
golem::add_test("mod_feature_name")  # scaffolds test-mod_feature_name.R
golem::use_recommended_tests()       # adds app-level shinytest2 setup
```

## Coverage Reporting

```r
# Run all tests and get coverage
coverage <- covr::package_coverage()

# Print summary to console
coverage

# Open interactive HTML report in browser
covr::report(coverage)

# Coverage for a specific file
covr::file_coverage("R/fct_data.R", "tests/testthat/test-fct_data.R")
```

**Coverage targets:**
- `fct_*.R` / `utils_*.R` functions: ≥ 90%
- Module servers: ≥ 70% (some reactive paths are hard to reach without browser)
- Overall package: ≥ 80%

## Running Tests

```r
# All tests
devtools::test()

# Specific test file
devtools::test(filter = "fct_data")

# With coverage
covr::package_coverage(quiet = FALSE)

# Load app for interactive testing
golem::run_dev()
```

## CI Integration (GitHub Actions)

Use `r-lib/actions/check-r-package` — it runs `devtools::check()` which includes all tests:

```yaml
# .github/workflows/R-CMD-check.yml
on: [push, pull_request]
jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::rcmdcheck
      - uses: r-lib/actions/check-r-package@v2
```

For coverage reporting add:
```yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::covr, any::xml2
      - name: Coverage
        run: covr::codecov(quiet = FALSE)
        shell: Rscript {0}
```

## Quick Reference

| Task | Command |
|------|---------|
| Run all tests | `devtools::test()` |
| Coverage report | `covr::report(covr::package_coverage())` |
| Record shinytest2 | `shinytest2::record_test(".")` |
| Scaffold module test | `golem::add_test("mod_name")` |
| Add new test file | `usethis::use_test("name")` |
| Check for failures | `devtools::check()` |


