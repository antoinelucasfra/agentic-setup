# Contributing

## Adding a Skill

Create a directory under `.agents/skills/<skill-name>/` with a `SKILL.md` file. See existing skills for format reference.

## Updating Setup Script

Edit `setup.sh`, then:
```bash
shellcheck setup.sh       # Verify no bash issues
./setup.sh --dry-run      # Confirm it still works
```

## Submitting Changes

1. Branch: `feat/<your-feature>`
2. Commit: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`)
3. Open a PR targeting `main`
