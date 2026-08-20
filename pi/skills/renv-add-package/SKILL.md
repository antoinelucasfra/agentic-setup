---
name: renv-add-package
description: Use this skill when asked to add, remove, or update an R package dependency in any R project in this workspace (fitness-app, groupOrganizeR, recipeR, or antoinelucasfra.github.io). Covers the correct renv workflow.
---

# Managing R package dependencies with renv

All R projects in this workspace use **renv**. Never call `install.packages()` standalone without updating the lockfile.

## Adding a package

```r
# 1. Install the package into the renv library
renv::install("package_name")

# 2. Use the package in your code (add to R/ files or .qmd chunks)

# 3. Snapshot to update renv.lock
renv::snapshot()
```

Always commit `renv.lock` after snapshotting.

## Adding a package from GitHub

```r
renv::install("owner/repo")
renv::snapshot()
```

## Removing a package

```r
# 1. Remove all uses from code
# 2. Then clean up renv
renv::remove("package_name")
renv::snapshot()
```

## Restoring the environment (e.g. after cloning)

```r
renv::restore()
```

## Updating a package

```r
renv::update("package_name")
renv::snapshot()
```

## Adding to DESCRIPTION (golem apps)

For golem apps (`fitness-app`, `groupOrganizeR`, `recipeR`), also add the package to the `Imports:` field in `DESCRIPTION`:

```
Imports:
    shiny,
    golem,
    new_package   # <- add here
```

Then run:
```r
attachment::att_amend_desc()  # if attachment is available, auto-updates DESCRIPTION
```

Or edit `DESCRIPTION` manually.

## For antoinelucasfra.github.io — also update CI

When adding a package used in a `.qmd` code chunk, also add it to `.github/workflows/publish.yml` in the `Install R packages` step:

```yaml
- uses: r-lib/actions/setup-r-dependencies@v2
  with:
    packages: |
      any::knitr
      any::rmarkdown
      any::new_package    # <- add here
```
