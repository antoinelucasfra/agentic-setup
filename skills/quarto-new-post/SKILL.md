---
name: quarto-new-post
description: Use this skill when asked to create a new blog post or article for the antoinelucasfra.github.io Quarto website. Covers file structure, frontmatter, R/Python chunks, and the publish workflow.
---

# Creating a new blog post for antoinelucasfra.github.io

## Step 1 — Create the post directory and file

Posts live in `posts/<post-slug>/index.qmd`. The slug should be lowercase, hyphen-separated, and descriptive:

```bash
mkdir posts/my-post-title
touch posts/my-post-title/index.qmd
```

## Step 2 — Write the frontmatter

```yaml
---
title: "Your Post Title"
description: "One or two sentence summary shown in the blog listing and OG tags."
date: "YYYY-MM-DD"
categories: [R, Python, Statistics]   # or whatever applies
image: thumbnail.png                   # optional — shown in listing
draft: false
---
```

Valid category values (use existing ones from the catalog when possible): `R`, `Python`, `Statistics`, `Machine Learning`, `Shiny`, `Quarto`, `Data Science`, `Pharma`, `NLP`, `Computer Vision`.

Set `draft: true` while writing — the post won't appear in the listing until changed to `false`.

## Step 3 — Write content

Standard Quarto markdown. For code chunks:

**R chunks:**
```{{r}}
#| label: my-chunk
#| echo: true
#| warning: false
library(ggplot2)
```

**Python chunks:**
```{{python}}
import pandas as pd
```

For inline citations, use `[@key]` with a `references.bib` file in the post directory.

## Step 4 — Add new R packages (if needed)

```r
# In R console at project root:
renv::install("new_package")
renv::snapshot()   # updates renv.lock — commit this
```

Also add to the `packages:` list in `.github/workflows/publish.yml` using `any::new_package` syntax.

## Step 5 — Preview and render

```bash
quarto preview                  # live preview
air format .                    # format any R code in chunks
quarto render                   # full render to docs/
```

## Step 6 — Commit (two separate commits)

```bash
# 1. Content commit
git add posts/my-post-title/
git commit -m "feat(blog): Add post on <topic>"

# 2. Render commit
git add docs/ _freeze/
git commit -m "render: Render website"
```

**Never** mix content changes and render output in the same commit.

## Hard rules

- Never edit anything in `docs/` manually — it is generated
- Never delete `_freeze/` — it is the code execution cache
- `output-dir` in `_quarto.yml` must stay `docs`
