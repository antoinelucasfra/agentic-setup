---
name: linksmith-new-adapter
description: Use this skill when asked to add support for a new bookmarking or note-taking source to linksmith. Covers the adapter interface, registration, and testing pattern.
---

# Adding a new source adapter to linksmith

Linksmith ingests URLs from multiple sources via a unified adapter interface. Each source has its own file in `linksmith/adapters/`.

## Step 1 — Create the adapter file

Create `linksmith/adapters/<source_name>.py`. Follow the existing adapter interface:

```python
from pathlib import Path
from typing import Iterator

from linksmith.models import RawURL


class <SourceName>Adapter:
    """Adapter for <SourceName>. Reads from <describe input format>."""

    name = "<source_name>"  # lowercase, matches filename

    def __init__(self, source: Path | str) -> None:
        self.source = Path(source)

    def read(self) -> Iterator[RawURL]:
        """Yield RawURL records from the source."""
        # Parse the source and yield RawURL objects
        # RawURL fields: url (str), title (str | None), tags (list[str]), source (str)
        for item in self._parse():
            yield RawURL(
                url=item["url"],
                title=item.get("title"),
                tags=item.get("tags", []),
                source=self.name,
            )

    def _parse(self):
        # Internal parsing logic
        raise NotImplementedError
```

## Step 2 — Register the adapter

Add it to `linksmith/adapters/__init__.py`:

```python
from linksmith.adapters.<source_name> import <SourceName>Adapter

ADAPTERS = {
    # ... existing adapters ...
    "<source_name>": <SourceName>Adapter,
}
```

## Step 3 — Wire into the CLI

In `linksmith/cli.py`, add the new source as a valid option in the `ingest` command. Follow the existing pattern for other adapters.

## Step 4 — Update settings (if needed)

If the adapter needs configuration (API key, file path, etc.), add a field to `linksmith/settings.py`:

```python
class Settings(BaseSettings):
    # ...
    <source_name>_path: Path | None = None
    <source_name>_api_key: str | None = None
```

## Step 5 — Write tests

Create `tests/test_adapter_<source_name>.py`:

```python
import pytest
from pathlib import Path
from linksmith.adapters.<source_name> import <SourceName>Adapter

def test_read_returns_raw_urls(tmp_path):
    # Create a sample input file
    sample = tmp_path / "sample.<ext>"
    sample.write_text("...")

    adapter = <SourceName>Adapter(sample)
    results = list(adapter.read())

    assert len(results) > 0
    assert all(r.source == "<source_name>" for r in results)
    assert all(r.url.startswith("http") for r in results)
```

## Step 6 — Verify

```bash
uv run pytest tests/test_adapter_<source_name>.py
uv run ruff check .
```
