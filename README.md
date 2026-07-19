# OMP Agentic Setup

Setup scripts and skills for the OMP coding agent harness.

## Quick Start

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh
```

## Usage

```bash
./setup.sh --help          # All options
./setup.sh --dry-run       # Preview
./setup.sh --list-skills   # List available skills
./setup.sh --uninstall     # Remove setup

make install               # Same as ./setup.sh
make validate              # Dry-run check
make skills                # List skills
```

## Contents

- `setup.sh` — installation script with dry-run, uninstall, and skill listing
- `.agents/AGENTS.md` — global instructions for the OMP agent
- `.agents/skills/` — 44 agent skill definitions
- `.agents/rules/` — code quality guidelines
- `docs/SETUP.md` — device-specific setup guide (Linux, macOS, WSL2)
- `docs/CONTRIBUTING.md` — how to add skills

## Requirements

- Bash 4+
- Git
- Curl
