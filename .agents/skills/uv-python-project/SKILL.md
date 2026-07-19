---
name: uv-python-project
description: Use this skill when working on any Python project in this workspace (fake-news-detection, voice-to-data, linksmith). Covers dependency management, running scripts, linting, and project hygiene with uv.
---

# Python project workflow with uv

All Python projects in this workspace use **uv** exclusively. Never use `pip`, `pip install`, `python -m pip`, `poetry`, or `conda`.

## Daily workflow

```bash
# Sync the environment (installs from uv.lock — deterministic)
uv sync

# Run any script
uv run script.py
uv run script.py --arg value

# Run tests
uv run pytest
uv run pytest tests/test_specific.py          # single file
uv run pytest tests/test_specific.py::test_fn  # single test

# Lint and format (ruff is always in dev dependencies)
uv run ruff check .
uv run ruff format .
uv run ruff check --fix .   # auto-fix safe issues
```

## Adding dependencies

```bash
# Production dependency
uv add <package>

# Dev-only dependency
uv add --dev <package>

# Pin a specific version
uv add "package>=1.2,<2.0"
```

Always commit `uv.lock` after running `uv add`.

## Ruff config (applies to all projects)

- `line-length = 100`
- `target-version = "py312"`
- Rules: `E F I UP B SIM` — ignore `E501` (line length — handled by formatter)
- Run `ruff format .` before committing — it is the single source of formatting truth

## Project-specific entry points

| Project | Run command |
|---|---|
| `fake-news-detection` | `uv run finetune.py`, `uv run evaluate.py --checkpoint <path>`, `uv run inference.py --claim "..."` |
| `voice-to-data` | `uv run pipeline.py <audio.mp3> <output.json>` |
| `linksmith` | `uv run main.py` or `linksmith` CLI after `uv sync` |

## Environment / secrets

Store secrets in a `.env` file (never committed). Load via `pydantic-settings` (`BaseSettings`) or `python-dotenv`. The `settings.py` file in each project is the canonical place for env-backed config.
