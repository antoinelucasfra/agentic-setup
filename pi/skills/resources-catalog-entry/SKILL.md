---
name: resources-catalog-entry
description: Use this skill when asked to add one or more resources to the antoinelucasfra.github.io resources catalog. Covers the required YAML format, valid field values, and the file to edit.
---

# Adding resources to the catalog

Resources live in `data/resources.txt` in the `antoinelucasfra.github.io` directory. Each entry is a YAML block separated by `---`.

## Format

```yaml
---
title: "Resource Title"
type: "Book"
link: "https://example.com"
language: "R"
category: "Shiny;Web Development"
description: "One or two sentence description of the resource. Max 300 characters."
---
```

## Required fields (all 6 are mandatory)

| Field | Rules |
|---|---|
| `title` | Display name, quoted string |
| `type` | Must be one of the valid values below |
| `link` | Full URL including `https://` |
| `language` | `R`, `Python`, `Other`, or combinations like `R;Python` |
| `category` | Topical tags, `;`-separated, no spaces around `;`, title case |
| `description` | Max 300 characters, plain text |

## Valid `type` values

`Blog` · `Book` · `Website` · `Package` · `Video` · `Paper` · `Course` · `Community` · `Newsletter` · `Conference` · `Forum` · `Journal` · `Repository`

## Category conventions

- Use `;` as separator with no surrounding spaces: `"Statistics;Mixed Models"`
- Use title case: `"Machine Learning"` not `"machine learning"`
- Reuse existing category tags where possible (check `projects/resources_catalog.qmd` for current tag list)

## Adding a resource

1. Open `data/resources.txt`
2. Append the new YAML block at the end of the file
3. Verify the format is correct
4. Commit with: `git commit -m "feat(catalog): Add <title>"`

Do **not** run `quarto render` just to add catalog entries — the catalog is rendered from `resources.txt` at build time.
