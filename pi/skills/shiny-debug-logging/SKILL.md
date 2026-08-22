---
name: shiny-debug-logging
description: >
  Expert debugging and logging for Shiny apps: interactive debugging of
  reactive code with browser() inside observe(), print debugging, UI debug
  panels with reactiveValuesToList(), reading Shiny call stacks, module
  isolation strategy, validate()/tryCatch() error handling, structured logging
  with the logger package, .onAttach() startup messages.
  USE FOR: any Shiny bug hunt — errors in server/modules/reactives, graph not
  rendering, inputs not updating, tracing module communication, adding logging,
  interpreting stack traces. USE PROACTIVELY when user reports a Shiny app bug.
  DO NOT USE FOR: non-reactive R debugging (standard browser()/debug()),
  writing tests (see shiny-spec-tests).
---

# Debugging & Logging Shiny Apps

Source: https://mjfrigaard.github.io/shiny-app-pkgs/ (chapters 10-13, appendix)

## Why Shiny debugging is different

Server code runs **asynchronously** in response to reactivity. A bare `browser()`
in a server function will NOT pause where you expect — there is no linear control
flow to pause. You must hook into the reactive engine itself.

## Golden rule: `browser()` inside `observe()`

```r
# inside server or moduleServer function
observe({
  browser()   # triggers when the observer is invalidated (deps change)
})
```

`observe()` listens for reactive dependencies and runs its body each time they
change — this is the one place `browser()` works reliably in Shiny. In modules,
place the `observe({browser()})` **after** the `moduleServer()` call.

Browser commands: `n` next line, `s` step into, `f` finish loop/function, `c`
continue, `Q` quit. IDE breakpoints are equivalent — but breakpoints in reactive
code still need an invalidation event to fire.

## Inspecting reactives in the debugger

A reactive is a function wrapping a value. This trips everyone:

```r
Browse> str(selected_aes)      # WITHOUT () → shows the METHOD/observable machinery
Browse> str(selected_aes())    # WITH ()    → shows the actual VALUES
```

If you see `attr(*, "observable")` / class `"reactiveExpr"`, you forgot the
parentheses. Calling it inside `observe()`/the debugger evaluates on demand.

## Method 2: print debugging in reactive context

Same principle — wrap prints so they run on invalidation:

```r
observe({
  cat("Selected x, y, color:\n")
  print(c('x' = input$x, 'y' = input$y, 'color' = input$z))
}) |> shiny::bindEvent(c(input$x, input$y, input$z))
```

Limits: snapshot only at print time; no pausing; must edit code per variable.

## Method 3: live debug panel in the UI (most powerful)

Display ALL reactive values, updating live, namespaced:

```r
# UI (or module UI) — ns <- NS(id) in modules
verbatimTextOutput(ns("vals"))

# server — app-level shows "module_id-input" names; module-level shows bare names
output$vals <- renderPrint({
  app_vals <- shiny::reactiveValuesToList(x = input, all.names = TRUE)
  str(app_vals)        # or lobstr::tree(app_vals) for prettier output
})
```

Key insight: `reactiveValuesToList()` at the **app server** level reveals full
namespaced IDs (`vars-y`, `aes-alpha`) — exactly what you pass to `AppDriver$set_inputs()`
in system tests. At **module** level you see bare names (`x`, `alpha`) — proving what
the module actually receives. Always set `all.names = TRUE`.

## Reading Shiny call stacks

Shiny stack traces read bottom-up: low numbers = outermost caller (`runApp`),
high numbers = deep in the failure. Learn the fixed Shiny scaffolding frames so you
can spot YOUR frames:

```
Warning: Error in tools::toTitleCase: 'text' must be a character vector
  208: stop                      ← error thrown here
  207: tools::toTitleCase        ← your culprit function
  206: <reactive>
  ...
  186: inputs                    ← YOUR reactive that failed
  178: renderPlot                ← YOUR render block
  ...
    3: runApp                    ← framework entry point
```

Ignore everything between `<reactive>`/`.func`/`ctx$run` frames — those are Shiny
internals. Your code appears as named reactives, observers, render functions, and
your own functions. The topmost *named* frame of yours is usually where to look first.

## Systematic module bug-hunt procedure

The book's worked example — follow this order:

1. **Map the app** with an AST before diving in:
   ```r
   lobstr::ast(launch_app())   # or sketch: launch_app → ui/server → mod_*_ui/server → utils
   ```
   Namespace mental model: "a namespace is to an ID as a directory is to a file."
2. **Verify inter-module handoff**: put `observe({browser()})` in the parent server
   (e.g., `movies_server`). Step until both module returns exist. Check
   `str(module_return)` — method vs values (see above). If both carry real values,
   the handoff is fine; the bug is downstream.
3. **Descend into the suspect module**: move `observe({browser()})` into the child
   module after `moduleServer()`. Step past creation of internal reactives.
4. **Reproduce the failing expression directly** in the browser:
   ```r
   Browse> tools::toTitleCase(aes_inputs()$plot_title)   # replay the exact call
   ```
   Compare against what the code SHOULD have referenced. (Real book bug: called
   `$x` instead of `$plot_title` — silent NULL → type error two frames away.)
5. Remove/comment all debug scaffolding; fix; load_all + document + install; rerun.

Pattern: **narrow scope from parent server → module boundary → reactive internals →
single expression**. Never fix based on the stack trace message alone; reproduce in
the browser first.

Uncoupling tip: split mega-input-modules into small ones (variables vs aesthetics)
so each graph element can be debugged independently.

## Proactive defense: validate() + tryCatch()

Prevent crashes instead of chasing them:

```r
# user-facing input validation — graceful message, no crash
validate(
  need(try(input$alpha >= 0 & input$alpha <= 1), "Alpha must be between 0 and 1")
)

# catch unexpected errors in render/reactive blocks, log, keep app alive
tryCatch({
  plot <- scatter_plot(df = movies, x_var = inputs()$x, ...)
}, error = function(e) {
  log_error(glue::glue("Failed to render scatterplot. Reason: {e$message}"))
})
```

Rule: `validate(need(...))` for *user input* problems; `tryCatch` + log for
*unexpected* errors; argument checks in exported fns use `stop()` early.

## Structured logging

Print debugging dies in production. Use the `logger` package (levels, sinks, thresholds):

- Levels: `TRACE` (fn entered/exited), `DEBUG`, `INFO` (app launched, arg values),
  `WARN` (input out of range), `ERROR` (render failed — pair with tryCatch),
  `FATAL` (launch failed — pair with stop()).
- Where: TRACE in each server/module fn body; INFO in `launch_app()`/UI builders;
  WARN next to validate(); ERROR in every tryCatch around renders; FATAL around app launch.
- Development threshold: `logger::log_threshold('TRACE')` before `launch_app()`.
- Search logs later: `readLines("_logs/app_log.txt") |> stringr::str_view("ERROR")`
  or shell `grep ERROR _logs/app_log.txt`.
- Wrap messages with `glue::glue()` for interpolation.

## Package startup diagnostics

Put `.onAttach()` in `R/zzz.R`: greet via `cli::cli_inform(..., class =
"packageStartupMessage")`, print current git branch, version, Imports/Suggests.
Useful when "works on my machine" bugs turn out to be wrong branch or stale install.

## Tool selection table

| Situation | Tool |
|---|---|
| Pause reactive execution | `observe({browser()})` |
| See all inputs live, namespaced | `reactiveValuesToList()` + `verbatimTextOutput` |
| One-off value check | `print()`/`cat()` in observe |
| Understand app structure | `lobstr::ast()`, `lobstr::tree()` |
| After-crash analysis | `traceback()`, `options(error = recover)` |
| Step through non-reactive utility fn | plain `debug(fn)` / `browser()` |
| Inject debugging into third-party fn | `trace(fn, tracer = browser)` |
| Production / post-deploy | logger package + log files |

## Cleanup discipline

Debug scaffolding (`observe/browser`, `verbatimTextOutput` panels) must never reach
a commit. Track it: add `# DEBUG:` comments at each insertion, grep before commit:
`git diff | grep -n "DEBUG:"`. Consider a helper like `.dev = FALSE` module arguments
(book's pattern) that toggles built-in debug output without code surgery.
