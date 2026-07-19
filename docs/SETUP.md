# Device Setup Guide

Platform-specific instructions for setting up the OMP coding agent harness.

## Prerequisites

### Linux (Debian/Ubuntu)
```bash
sudo apt update && sudo apt install -y curl git
```

### macOS
```bash
brew install git curl
```

### Windows (WSL2)
Install WSL2, then follow Linux instructions above.

## Installation

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh
```

## Verification

```bash
./setup.sh --dry-run       # Preview without making changes
./setup.sh --list-skills   # List available agent skills
make validate              # Same as --dry-run (if Makefile present)
```

## Uninstall

```bash
./setup.sh --uninstall
```
