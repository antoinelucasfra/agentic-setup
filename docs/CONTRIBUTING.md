# ⭐ Contributing Guidelines

Thank you for your interest in contributing to the OMP Agentic Setup! This document guides you through adding new skills, updating existing ones, and maintaining the harness.

## 🎯 What We're Looking For

We welcome contributions that:
- Add new skills for development workflows
- Improve existing skill documentation
- Fix bugs in automation scripts
- Enhance platform compatibility
- Add new rules or update existing ones
- Improve the setup experience

## 🚀 Quick Start

```bash
# 1. Fork and clone the repository
rtk git clone https://github.com/your-username/agentic-setup.git
rtk cd agentic-setup

# 2. Create a feature branch
rtk git checkout -b feat/your-feature

# 3. Make your changes (see below)

# 4. Test your changes
rtk make test-env

# 5. Commit and push
rtk git add .
rtk git commit -m "feat: add your feature"
rtk git push origin feat/your-feature

# 6. Open a Pull Request via GitHub web
```

## 📁 Repository Structure

```
agentic-setup/
├── .github/
│   └── workflows/          # CI/CD pipelines
├── .agents/
│   ├── AGENTS.md          # Global instructions
│   ├── skills/
│   │   └── <skill-name>/
│   │       ├── SKILL.md   # Skill definition
│   │       ├── README.md  # Skill documentation
│   │       └── examples/  # Example usage
│   └── rules/             # Code quality rules
├── scripts/
│   ├── setup.sh           # Installation script
│   └── validate.sh        # Validation script
├── docs/
│   ├── SETUP.md           # Device setup guide
│   └── CONTRIBUTING.md    # This file
├── Makefile              # Common commands
└── README.md             # Project overview
```

## 🛠️ Adding a New Skill

### Step 1: Create Skill Directory

```bash
# Create the skill directory
mkdir -p .agents/skills/<skill-name>
```

### Step 2: Create SKILL.md

```markdown
# <Skill Name>

Brief description of what this skill does and when to use it.

## When to Use

Use this skill when [specific conditions]. It handles [specific tasks].

## How It Works

The skill follows this workflow:
1. First step
2. Second step
3. Third step

## Example Usage

Example code or command demonstrating the skill:

```bash
# Example command
example-command --with-options
```

### Step 3: Add Documentation

Create `.agents/skills/<skill-name>/README.md`:

```markdown
# <Skill Name>

Detailed documentation for the skill.

## Overview
Description of the skill's purpose and capabilities.

## Requirements
List of dependencies or prerequisites.

## Configuration
Any configuration needed.

## Examples
Detailed examples of usage.

## Related Skills
Links to related skills or resources.
```

### Step 4: Update Skills Index

Add your skill to the main README.md skills list or create an index file.

### Step 5: Validate

```bash
# Test the skill structure
bash scripts/validate-skill.sh <skill-name>

# Or run full validation
make validate
```

## 🔧 Updating Existing Skills

### Finding Skills to Update

```bash
# List skills needing updates
rtk make skills-check

# Check for outdated skills
rtk make skills-outdated
```

### Making Changes

1. Read the existing SKILL.md to understand the current implementation
2. Make minimal changes focused on the specific improvement
3. Update documentation if behavior changes
4. Test with real use cases

### Testing Skills

```bash
# Test a specific skill
make test-skill SKILL=<skill-name>

# Run all skill tests
make test-all-skills

# Validate skill structure
scripts/validate-skill.sh <skill-name>
```

## 📏 Code Standards

### Markdown Formatting

- Use ATX-style headers (`#` not underline)
- Include emoji in headers (🎯 📁 🛠️)
- Use code blocks with language specifiers
- Keep lines under 100 characters
- Use relative links where possible
- Include alt text in images

```markdown
# ✅ Good Example

This is a well-formatted skill description.

```bash
# Example with language specifier
echo "Hello, World"
```

![Diagram](diagram.png)
*Figure 1: System architecture*
```

### Script Standards

```bash
# Use bash (not sh) for consistency
#!/usr/bin/env bash

# Set strict mode
set -euo pipefail

# Include header comment
# ============================================================
# Script Name - Brief Description
# ============================================================

# Use descriptive variable names
VERBOSE=${VERBOSE:-false}

# Validate inputs early
if [[ ! -d "$SCRIPT_DIR" ]]; then
  echo "Error: Script directory not found" >&2
  exit 1
fi

# Provide helpful usage output
usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help    Show this message
  -v, --verbose Enable verbose output
EOF
}
```

### Skill Documentation Template

Every skill should follow this structure:

```markdown
# Skill Name

One-line description.

## When to Use

Clear conditions for when this skill applies.

## How It Works

Step-by-step explanation.

## Example

```example
Example code here
```

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| param1 | string | What it does |
```

## 🧪 Testing Your Changes

### Local Testing

```bash
# Run all validation checks
make validate

# Test specific components
make test-setup       # Test setup script
make test-skills      # Test skills
make test-rules       # Test rules
```

### CI Testing

All PRs go through automatic testing:
- Shellcheck for scripts
- Markdown linting
- Skill structure validation
- Platform-specific tests

## 📝 Commit Messages

Follow conventional commits:

```
feat: add docker-deployment skill
fix: correct rtk proxy timeout in setup.sh
docs: improve SETUP.md platform instructions
chore: update skill version references
test: add validation for skill parameters
```

## 🆘 Getting Help

- Open an issue for bugs or suggestions
- Check existing issues before creating new ones
- Join discussions for questions
- Tag maintainers for urgent issues

## 📜 License

By contributing, you agree that your contributions will be licensed under the project's license (MIT/Apache-2.0).

## 🎉 Recognition

Contributors are recognized in:
- Git history
- Release notes
- Contributors list (on request)

---

Thank you for making OMP Agentic Setup better for everyone!