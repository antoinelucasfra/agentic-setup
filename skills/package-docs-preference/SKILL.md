---
name: package-docs-preference
description: Favor context7 tools (resolve-library-id, query-docs) over generic web_search when the user asks about R or Python package/library documentation. Use when the user mentions an R package (e.g., dplyr, ggplot2, tidyr, shiny, plumber), a Python library (e.g., pandas, numpy, scikit-learn, pydantic, fastapi, polars), or asks "what's the API", "how do I use X function", "up-to-date docs for Y", or "latest version docs for Z".
metadata:
  author: tonio
  version: "1.0"
---

## Documentation Lookup Preference

When the user asks about documentation, API usage, or code examples for R packages or Python libraries, you MUST prefer **context7** tools over generic `web_search`.

### Primary Toolchain

1. **`resolve-library-id`** — Search for the library/package to get its Context7 library ID.
   - Use the official package name (e.g., `"dplyr"`, `"ggplot2"`, `"pandas"`, `"numpy"`, `"shiny"`, `"quarto"`)
   - Returns results with library ID, description, snippet count, and versions

2. **`query-docs`** — Query version-specific documentation and code examples.
   - Pass the library ID from step 1 and a specific question
   - Returns structured docs with code examples pulled from source repos

### When to Fall Back to web_search

- context7 returns no results for the library
- The question is about a non-R/non-Python library context7 doesn't cover
- The user needs real-time information context7 can't provide (e.g., package status on CRAN, latest CRAN release date)
- You've already tried `resolve-library-id` and `query-docs` and got insufficient results

### DO NOT

- Skip context7 and go straight to `web_search` for R/Python package docs
- Use `web_search` when the user has already identified a package by name or function


