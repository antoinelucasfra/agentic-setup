# 🖥️ Device Setup Guide

This document provides detailed, device-specific instructions for setting up the OMP coding agent harness on new devices.

## 📋 Overview

The OMP coding agent is designed to work across multiple platforms with minimal configuration. This guide will help you set up the environment on any compatible device.

## 🛠️ Prerequisites by Platform

### Linux (Ubuntu/Debian)

```bash
# 1. Update system
rtk sudo apt update && rtk sudo apt upgrade -y

# 2. Install core dependencies
rtk sudo apt install -y \
  curl \
  git \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libsqlite3-dev \
  libffi-dev \
  libbz2-dev \
  liblzma-dev \
  jq \
  ripgrep

# 3. Install modern CLI tools (optional but recommended)
rtk sudo apt install -y \
  bat \
  dust \
  procs \
  delta \
  tree \
  htop

# 4. Install RTK (Token-Optimized CLI)
rtk curl -fsSL https://raw.githubusercontent.com/toniothomas/rtk/main/install.sh | bash

# 5. Restart shell or source profile
source ~/.bashrc
```

### macOS (Intel & Apple Silicon)

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install core dependencies
rtk brew install \
  git \
  curl \
  jq \
  ripgrep \
  openssl \
  readline \
  sqlite3

# 3. Install modern CLI tools
rtk brew install \
  bat \
  dust \
  procs \
  delta \
  eza \
  btm

# 4. Add Homebrew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 5. Install RTK
rtk curl -fsSL https://raw.githubusercontent.com/toniothomas/rtk/main/install.sh | bash

# 6. Restart shell
source ~/.zshrc
```

### Windows (WSL2)

```bash
# 1. Install WSL2 (if not already installed)
wsl --install

# 2. Inside WSL, follow Linux instructions above
# This is a fresh Ubuntu/Debian environment inside Windows

# 3. Optional: Install Windows-specific tools
# In PowerShell (as Administrator):
# winget install Microsoft.VisualStudioCode
# winget install Junegunn.fzf
```

## 🚀 Installation Methods

### Method 1: Automated Setup (Recommended)

```bash
# Clone the repository
rtk git clone https://github.com/antoinelucasfra/agentic-setup.git

# Navigate to the directory
rtk cd agentic-setup

# Run the setup script
rtk bash setup.sh

# Validate installation
rtk bash scripts/validate.sh
```

### Method 2: Manual Installation

```bash
# 1. Create agent directory
rtk mkdir -p ~/.agents/{skills,rules,scripts}

# 2. Copy AGENTS.md
rtk curl -o ~/.agents/AGENTS.md https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/AGENTS.md

# 3. Clone skills repository
rtk git clone https://github.com/antoinelucasfra/agentic-skills.git ~/.agents/skills

# 4. Copy rules
rtk curl -o ~/.agents/rules/code-style.md https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/rules/code-style.md
rtk curl -o ~/.agents/rules/security.md https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/rules/security.md

# 5. Install scripts
rtk curl -o ~/.agents/scripts/validate.sh https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/validate.sh
rtk chmod +x ~/.agents/scripts/validate.sh

# 6. Verify installation
rtk ~/.agents/scripts/validate.sh
```

### Method 3: Containerized Setup

```bash
# Run in a container with all tools pre-installed
rtk docker run -it --rm \
  -v ~/.agents:/home/omp/.agents \
  -v $(pwd):/workspace \
  antoinelucasfra/omp-harness:latest \
  /bin/bash
```

## ⚙️ Environment Configuration

### Shell Configuration

Add the following to your `~/.bashrc`, `~/.zshrc`, or `~/.profile`:

```bash
# OMP Agent Configuration
export OMP_HOME="$HOME/.agents"
export AGENTS_FILE="$HOME/.agents/AGENTS.md"
export AGENTS_DIR="$HOME/.agents"
export PATH="$HOME/.agents/scripts:$PATH"

# RTK Configuration (if installed)
if command -v rtk &> /dev/null; then
  export RTK_TOKEN_SAVINGS=1
  export RTK_PROXY=1
fi

# Modern CLI Aliases
alias cat="bat"
alias ls="eza --color=auto"
alias tree="eza --tree"
alias grep="rg"
alias du="dust"
alias df="duf"

# OMP Agent Aliases
alias omp-install="bash $HOME/.agents/setup.sh"
alias omp-validate="bash $HOME/.agents/scripts/validate.sh"
alias omp-skills="ls $HOME/.agents/skills"

# Load RTK if available
if command -v rtk &> /dev/null; then
  alias rtk-gain="rtk gain"
  alias rtk-discover="rtk discover"
fi
```

### Terminal Configuration

#### iTerm2 (macOS)
```bash
# 1. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 2. Install Powerlevel10k theme
rtk git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# 3. Set theme in ~/.zshrc
echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc

# 4. Install Nerd Fonts for icons
rtk brew tap homebrew/cask-fonts
rtk brew install font-jetbrains-mono-nerd-font
```

#### Windows Terminal
```powershell
# 1. Install Windows Terminal from Microsoft Store

# 2. Install Cascadia Code Nerd Font
rtk winget install --id=Microsoft.CascadiaCode.NF

# 3. Configure Windows Terminal profile
# Add to settings.json:
# {
#   "guid": "{omp-agent}",
#   "hidden": false,
#   "name": "OMP Agent",
#   "commandline": "wsl.exe",
#   "icon": "/mnt/c/Users/tonio/.icons/omp-icon.png",
#   "fontFace": "Cascadia Code Nerd Font",
#   "fontSize": 10
# }
```

## 🌐 Network Configuration

### Proxy Setup (Corporate Networks)

```bash
# Configure RTK to work with corporate proxy
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="https://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.internal.company.com"

# For the setup script
rtk export http_proxy="http://proxy.company.com:8080"
rtk export https_proxy="https://proxy.company.com:8080"
```

### Offline Installation

```bash
# 1. Download all files while online
rtk mkdir -p /tmp/omp-offline
rtk curl -L -o /tmp/omp-offline/AGENTS.md https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/AGENTS.md

# 2. Copy to target machine via USB
# On target machine:
rtk mkdir -p ~/.agents
rtk cp /media/usb/omp-offline/AGENTS.md ~/.agents/
```

## 🔧 Platform-Specific Notes

### Linux Specifics

```bash
# Ubuntu: Enable systemd services for background tasks
sudo systemctl enable omp-agent.timer

# Fedora: Use dnf instead of apt
sudo dnf install curl git

# Arch: Use pacman
sudo pacman -S curl git
```

### macOS Specifics

```bash
# Apple Silicon: Rosetta 2 for x86 tools
rtk softwareupdate --install-rosetta

# Install xcode command line tools
xcode-select --install

# Set up oh-my-zsh plugins
echo "plugins=(git docker kubectl npm npx)" >> ~/.zshrc
```

### WSL2 Specifics

```bash
# Enable systemd in WSL2 (requires wsl2-systemdAUR or similar)
# Or use service command alternatives

# Set up Windows integration
# Access Windows files from WSL: /mnt/c/
# Access WSL from Windows: use wsl.exe

# Performance optimization
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

## 🧪 Validation Steps

After installation, run these validation commands:

```bash
# 1. Check AGENTS.md is accessible
rtk cat ~/.agents/AGENTS.md | head -20

# 2. Verify skill installation
rtk ls ~/.agents/skills/ | wc -l
rtk ls ~/.agents/skills/devops-expert/

# 3. Test RTK
rtk rtk gain --status

# 4. Validate shell configuration
rtk echo $OMH_HOME
rtk which omp-install

# 5. Test a skill
rtk rtk agent plan "Create a simple R function"
```

## 📊 Configuration Files

### AGENTS.md Location
```
Location: ~/.agents/AGENTS.md
Purpose: Global agent instructions loaded for every session
Update: rtk git -C ~/.agents pull
```

### Skills Directory
```
Location: ~/.agents/skills/
Structure:
├── devops-expert/
│   ├── SKILL.md
│   └── examples/
├── shiny-bslib/
│   ├── SKILL.md
│   └── references/
└── ...
```

### Rules Directory
```
Location: ~/.agents/rules/
Files:
├── code-style.md          # Style guidelines
├── security.md            # Security rules
├── commit-workflow.md     # Git commit standards
└── ...
```

## 🆘 Troubleshooting

### Common Issues

**RTK not found after installation:**
```bash
# Check if it's in PATH
rtk echo $PATH | tr ':' '\n' | grep rtk

# Add to PATH manually
echo 'export PATH="$HOME/.rtk/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Skills not loading:**
```bash
# Verify skills directory
rtk ls -la ~/.agents/skills/

# Check SKILL.md exists in each skill
rtk find ~/.agents/skills -name "SKILL.md" | wc -l

# Reinstall if missing
rtk bash ~/.agents/setup.sh --reinstall-skills
```

**Permissions issues:**
```bash
# Fix permissions
rtk chmod -R 755 ~/.agents
rtk chmod +x ~/.agents/scripts/*.sh
```

## 📈 Performance Tuning

### Token Optimization
```bash
# Check token savings
rtk rtk gain

# Enable aggressive filtering
export RTK_AGGRESSIVE=1

# Monitor missed opportunities
rtk rtk discover
```

### Shell Performance
```bash
# Optimize shell startup
echo 'export DISABLE_UPDATE_PROMPT=1' >> ~/.bashrc

# Lazy load heavy plugins
echo 'zstyle ":omz:plugins" disable docker kubectl npm' >> ~/.zshrc
```

## 🔐 Security Considerations

### Secure Installation
```bash
# Verify script integrity before running
rtk curl -L https://github.com/antoinelucasfra/agentic-setup/main/setup.sh | rtk shasum -a 256

# Compare with expected hash from repository
```

### Environment Security
```bash
# Don't store secrets in AGENTS.md
# Use environment variables for sensitive data
# Add to .gitignore if you create local config
echo ".env" >> ~/.gitignore
```

## 🔄 Updates and Maintenance

### Self-Update
```bash
# Update AGENTS.md
rtk cd ~/.agents && rtk git pull

# Update all skills
rtk for skill in ~/.agents/skills/*/; do
  rtk cd "$skill" && rtk git pull
done

# Update rules
rtk cd ~/.agents/rules && rtk git pull
```

### Scheduled Updates
```bash
# Add to crontab for weekly updates
# 0 9 * * 0 rtk bash ~/.agents/scripts/update-all.sh

# Or use systemd timer
# See systemd/omp-update.timer for configuration
```

---

*For platform-specific issues, check the [GitHub Issues](https://github.com/antoinelucasfra/agentic-setup/issues) or open a new issue with your platform details.*