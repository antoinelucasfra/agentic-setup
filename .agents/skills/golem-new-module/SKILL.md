---
name: golem-new-module
description: Use this skill when asked to add a new feature, tab, page, or section to a golem Shiny app (fitness-app, groupOrganizeR, or recipeR). Guides the full pattern for creating a Shiny module and wiring it into the app.
---

# Creating a new golem Shiny module

Follow this pattern exactly when adding a new feature to any golem app in this workspace (`fitness-app`, `groupOrganizeR`, `recipeR`).

## Step 1 — Create the module file

Create `R/mod_<name>.R`. The file must contain both the UI and server functions:

```r
#' <Name> UI
#' @param id Module namespace ID
#' @export
mod_<name>_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # UI elements here — use ns() to wrap all IDs
    # e.g. textInput(ns("my_input"), "Label")
  )
}

#' <Name> Server
#' @param id Module namespace ID
#' @param ... Pass shared reactive dependencies (e.g. db_pool, user_session)
#' @export
mod_<name>_server <- function(id, ...) {
  moduleServer(id, function(input, output, session) {
    # Logic here

    # Return a named list of reactives for downstream modules to consume
    list(
      result = reactive({ NULL })
    )
  })
}
```

Key rules:
- Always use `ns()` from `NS(id)` for every UI element ID
- Server returns a **named list of `reactive()` values**, never raw values
- Do not open DB connections inside modules — receive `db_pool` as a parameter

## Step 2 — Wire the UI into `app_ui.R`

Add the module's UI call to the appropriate place (tab, navbarPage, sidebar, etc.):

```r
# In app_ui.R, inside the relevant tab or navigation element:
mod_<name>_ui("mod_<name>")
```

## Step 3 — Wire the server into `app_server.R`

```r
# In app_server.R, inside the server function body:
mod_<name>_out <- mod_<name>_server("mod_<name>", db_pool = pool, ...)
```

Pass the return value to other modules that depend on it.

## Step 4 — Update DESCRIPTION

Add any new R package dependencies to the `Imports:` field in `DESCRIPTION`.

## Step 5 — Add tests

Create `tests/testthat/test_<name>.R` for any pure utility functions extracted from the module. Do not try to test reactive logic directly — test the underlying utility functions.

## Step 6 — Verify

```r
devtools::load_all()
devtools::test()
```
