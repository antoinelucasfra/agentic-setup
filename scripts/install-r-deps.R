# Install R packages used by the OMP agent config
#
# Run:  Rscript scripts/install-r-deps.R
#
# This installs R packages that skills and commit gates reference.
# CLI tools (air, jarl, uv, ruff, gh, quarto, etc.) are installed
# separately via the setup script — see README.md.

pkgs <- c(
  # Commit gates — referenced by git-workflow skill
  "devtools",   # devtools::test(), devtools::check()
  "testthat",   # test runner
  "lintr",      # lintr::lint_dir()

  # R package development — referenced across R skills
  "usethis",    # project automation
  "roxygen2",   # .Rd documentation
  "renv",       # dependency management
  "pkgdown",    # site builder
  "golem",      # Shiny app framework
  "withr",      # temporary state for tests
  "dockerfiler" # Dockerfile generation (golem)
)

installed <- rownames(installed.packages())
to_install <- setdiff(pkgs, installed)

if (length(to_install) == 0) {
  message("All required R packages are already installed.")
  invisible(FALSE)
}

message("Installing ", length(to_install), " R packages: ",
        paste(to_install, collapse = ", "), " ...")
install.packages(to_install, repos = "https://cran.r-project.org")

# Verify
still_missing <- setdiff(to_install, rownames(installed.packages()))
if (length(still_missing) > 0) {
  warning("Failed to install: ", paste(still_missing, collapse = ", "))
  invisible(TRUE)
} else {
  message("All packages installed successfully.")
  invisible(FALSE)
}
