# OMP Coding Agent — Global Instructions

Standing, always-loaded instructions for the OMP coding agent. These apply to
every project and every session, loaded globally from `~/.agents/AGENTS.md`.

## Tool selection (first)

- Prefer the harness's specialized tools — `glob`, `read`, `grep`, `edit`,
  `write`, `lsp` — over raw shell for listing, searching, and reading files.
  Do **not** route exploration through `ls` / `find` / `grep` / `cat` in bash.
- Shell out only when a real subprocess is required (builds, git, docker,
  data pipelines, inspection).

## RTK — token-optimized CLI (global)

**rtk** is a CLI proxy that filters and compresses command outputs, saving
60–90% tokens. Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

### Meta commands (use directly)

```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```
