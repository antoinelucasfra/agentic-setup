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

## Modern CLI over legacy utilities

When you must shell out, prefer a modern, actively maintained, faster/cleaner
replacement when one is installed and available.

### Scope — what this covers

The harness already mandates its own specialized tools over `ls` / `find` /
`grep` / `cat` for listing, searching, and reading files. **Do not re-shell
those.** This covers operations the specialized tools do not provide:
process/disk/network inspection, diffing, archives, and data transform inside
a pipeline.

### Rule

- Prefer the modern tool **only if it is installed in the current environment**;
  otherwise fall back to the standard utility. Do not assume it exists in
  CI/remote shells.
- Never trade correctness, security, or edge-case handling for speed.
- Keep the `rtk` prefix where the RTK proxy is active — modern tool choice is
  orthogonal to token-saving rewriting.

### Replacements (legacy → modern)

| Legacy | Modern | Use for |
| --- | --- | --- |
| `ps` / `top` / `htop` | `procs` / `btm` (bottom) | process & live resource inspection |
| `du` | `dust` | disk usage by directory |
| `df` | `duf` | filesystem / disk free |
| `diff` (ad hoc) | `delta` / `difft` | human-readable diffs |
| `unzip` / `tar` / mixed | `ouch` | create / extract any archive format |
| `cat` (view) | `bat` | viewing with highlighting in a terminal |
| `sed` (simple subs) | `sd` | simple find/replace in pipelines |
| `dig` / `nslookup` | `dog` | DNS lookups |
| `traceroute` / `mtr` | `trippy` | network path diagnosis |
| `man` | `tldr` / `cheat` | condensed examples |
| `tree` | `eza --tree` | directory tree |
| JSON / YAML in shell | `jq` / `yq` | query / transform structured data |

### Out of scope (keep standard)

`git`, `docker`, `kubectl`, build/test runners, `ssh`, `curl` — use them
directly; reach for modern wrappers only if already in use in the target
environment.
