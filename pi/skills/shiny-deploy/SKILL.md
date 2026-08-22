---
name: shiny-deploy
description: >
  Deploy and publish Shiny app-packages: shinyapps.io via rsconnect, Docker
  with rocker/shiny base image, GitHub Actions workflows (style/lint, deploy,
  docker build), pkgdown documentation sites. USE FOR: deploying an
  app-package anywhere, writing Dockerfiles for Shiny apps, setting up CI/CD,
  building a pkgdown site.
  DO NOT USE FOR: local dev workflow (see shiny-app-pkg), testing (see
  shiny-testing).
---

# Deploying Shiny App-Packages

Source: https://mjfrigaard.github.io/shiny-app-pkgs/ (chapters 19-22)

## shinyapps.io (rsconnect)

```r
# one-time account setup
rsconnect::setAccountInfo(name = "<account>", token = "<token>", secret = "<secret>")

# deploy — for an app-package, point at the standalone app function's app object
rsconnect::deployApp(appFileManifest = ..., appName = "myapp")
```

- The `rsconnect/` folder created after first deploy holds deployment records — commit it
  or `.Rbuildignore` it consistently across the team.
- Read deploy logs in the dashboard; runtime errors show up in **app logs** — this is
  where structured logging (logger package) pays off, since interactive debugging is gone.

## Docker

Self-contained deployment, no host R fiddling. Standard pattern:

```dockerfile
FROM rocker/shiny:latest

RUN R -e 'install.packages(c("remotes", "pak"))'
# install package deps (or the package itself)
COPY . /root/myapp
RUN R -e 'remotes::install_local("/root/myapp", dependencies = TRUE)'

EXPOSE 3838
CMD ["R", "-e", "library(myapp); options(shiny.port = 3838, shiny.host = '0.0.0.0'); launch_app()"]
```

```bash
docker build -t myapp .
docker run --rm -p 3838:3838 myapp    # then open localhost:3838
```

golem apps ship `docker/Dockerfile` conventions; plain app-packages work fine with the
pattern above. Pin the rocker version tag for reproducibility.

## GitHub Actions

YAML under `.github/workflows/`. Three canonical workflows from the book:

1. **Style/lint**: run `styler` + `lintr` on PRs (r-lib actions: `r-lib/actions/check-r-package`,
   or a style job that fails on diff after `styler::style_pkg()`).
2. **Deploy to shinyapps.io**: secrets `SHINYAPPS_NAME/TOKEN/SECRET` →
   `rsconnect::deployApp()` job triggered on main-branch push.
3. **Build & push Docker image**: docker/build-push-action, optionally deploy to a container host.

Keep test job (`devtools::test()`) ahead of any deploy step — never deploy red.

## pkgdown site

Doubles as documentation QA: if the site builds, your docs/NAMESPACE are consistent.

```r
usethis::use_pkgdown_github_pages()   # sets up _pkgdown.yml + GH Pages branch + Action
# customize _pkgdown.yml (function reference grouping matches @family tags)
pkgdown::build_site_github_pages()
```

Group module UI/server pairs and utility functions into reference sections mirroring
your `@family` tags.

## Deployment decision guide

| Target | When |
|---|---|
| shinyapps.io | Fastest path, Posit-managed, per-hour pricing |
| Docker (own server / cloud) | Full control, pinned deps, org infrastructure |
| GHA deploy job | Automation of either of the above |

Whatever the target, the app-package structure is what travels: `launch_app()` +
`DESCRIPTION` deps are all the host needs to reproduce your environment.
