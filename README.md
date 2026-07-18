# 🎮 OMP Agentic Setup

This repository contains everything needed to set up and use the OMP coding agent harness across devices.

## 📦 Contents
- **AGENTS.md**: Global instructions for the OMP agent
- **scripts/**: Automated setup and validation scripts
- **skills/**: All available agent skills
- **rules/**: Code quality and assistance guidelines
- **docs/**: Complete documentation

## 🔧 Getting Started

### Quick Installation
```bash
# Clone the repository
rm -rf ~/*.agentic-setup
Git clone https://github.com/antoinelucasfra/agentic-setup.git

# Make setup script executable
chmod +x ~/*.agentic-setup/setup.sh

# Run the setup script
~/.agentic-setup/setup.sh
```

### Options
```bash
~/.agentic-setup/setup.sh --help          # Show all options
~/.agentic-setup/setup.sh --list-skills    # List available skills
~/.agentic-setup/setup.sh --dry-run        # Test without changes
~/.agentic-setup/setup.sh --uninstall       # Remove setup
```

## 📚 Documentation

### Quick Links
- [🐋 AGENTS.md](.github/README.md#AGENTS.md) - Core harness instructions
- [📖 SETUP.MD](.github/README.md#SETUP.MD) - Device-specific setup
- [💼 CONTRIBUTING.MD](.github/README.md#CONTRIBUTING.MD) - Contribution guidelines
- [🛠️ Makefile](.github/README.md#Makefile) - Common automation commands

## 🛠️ Automation Commands

All commands are available via the Makefile:

```bash
# Install the harness (default)
make install

# Validate the installation
make validate

# List available skills
make skills

# Uninstall
make clean

# Test environment setup
make test-env

# Update all skills
make skills-update

# Run validation and upgrade if needed
make check-upgrade
```

## 🎯 Installation Steps

### 1. System Check
The setup script automatically validates:

- **Bash version**: 4+ recommended
- **Required commands**: git, curl
- **Operating system**: Linux, macOS, or other Unix-like
- **Environment**: Appropriate shell and permissions

### 2. Installation Options

```bash
# Basic installation
~/.agentic-setup/setup.sh

# Installation with skill selection
~/.agentic-setup/setup.sh --install-skill "skill-name-1" --install-skill "skill-name-2"

# Installation without validation
~/.agentic-setup/setup.sh --skip-system

# Test mode (show what would be done)
~/.agentic-setup/setup.sh --dry-run
```

### 3. Post-Installation

After installation, you'll have:

```
$(whoami)/.agents/
├── AGENTS.md                    # Global instructions
├── skills/                      # All agent skills
│   ├── devops-expert/SKILL.md   # Example skill
│   └── another-skill/
├── rules/                       # Code quality guidelines
├── scripts/                     # Automation scripts
└── README-agent.md              # Agent-specific setup guide
```

## 🚀 Setup Script Features

### System Validation
- Checks bash version compatibility
- Verifies required commands are installed
- Discovers and validates the OS
- Reports any issues with specific recommendations

### Flexible Installation
- **All skills (default)**: Comprehensive setup
- **Skill selection**: Install only specific skills
- **Selective components**: Skip system checks for known environments
- **Dry run**: Test without making changes
- **Uninstall capability**: Clean removal

### Comprehensive Skills Setup
- **Skill organization**: Each skill is installed in its own directory
- **SKILL.md requirement**: Validates each skill contains necessary structure
- **Automatic dependency management**: Prepares skills for use

### Validation and Reporting
- **Installation validation**: Checks all components are present and functional
- **Skill validation**: Verifies each skill meets basic requirements
- **Detailed reporting**: Shows what was installed and any issues found
- **Token savings reporting**: Demonstrates the benefit of RTK

## 🛠️ Automation Commands (Makefile)

### Installation Commands

```bash
# make install  - Installs the complete harness
# This runs the setup script in batch mode without interactive prompts

# make validate - Validates the installed environment
# This runs the validation script which checks all components

# make skills - Lists all available skills
# This dynamically discovers and lists skills from skills/*.skillet

# make clean - Uninstalls and cleans up
# This removes .agents directory and reverses installation

# make test-env - Test environment setup
# This runs a comprehensive test of the environment

# make skills-update - Updates skills to the latest versions
# This syncs skills with the repository

# make check-upgrade - Validate and upgrade if needed
# This checks for updates and upgrades if available
```

## 📖 Usage Examples

### Basic Usage
```bash
# First time setup (installs everything)
~/.agentic-setup/setup.sh

# Validate installation
~/.agentic-setup/scripts/validate.sh

# Custom skill installation
~/.agentic-setup/setup.sh --install-skill "devops-expert" --install-skill "shiny-bslib"
```

### Advanced Usage
```bash
# Installation with verbose output
~/.agentic-setup/setup.sh --verbose --skip-system

# List and examine skills
~/.agentic-setup/setup.sh --list-skills
~/.agentic-setup/setup.sh --dry-run --install-skill "example-skill"

# Uninstall and re-install
~/.agentic-setup/setup.sh --uninstall
~/.agentic-setup/setup.sh --install-skill "devops-expert" --install-skill "shiny-bslib"
```

## 🎲 Skill Categories

### 🤖 Development Skills
- **DevOps Automation**: DevOps workflows and best practices
- **R Shiny**: Shiny app development with BSLib
- **Testing**: Comprehensive test writing and validation

### 📊 Data Analysis Skills
- **Python**: Data analysis, statistics, and machine learning
- **R**: Statistical analysis and data science workflows

### 🔧 Advanced Skills
- **AI Implementation**: Large language model integration
- **Package Development**: R package development and maintenance

## 🏆 Prerequisites

### System Requirements
```bash
# Ubuntu/Debian
$ sudo apt update && sudo apt install -y curl git

# macOS (with Homebrew)
$ brew install curl git

# This setup script supports:
• Bash 4+
• Git
• Modern shell features
• Internet connectivity (for package installation)
```

### Optional Dependencies
```bash
# RTK (Token Optimized CLI) - recommended
# This is a tool that saves 60-90% tokens on shell commands
# See AGENTS.md for more details on token optimization

# Modern CLI Tools
# Procs/btm - process monitoring
# Dust - disk usage analysis
# Duuf - filesystem analysis
# Various other modern tools for better performance
```

## 🚨 Troubleshooting

### Common Issues

**If the setup script fails:**
```bash
# Check if directories exist
$ ls -la ~/.agents

# Manually install
$ cp -r ~/.agentic-setup/.agents/*.md ~/.agents/
$ cp -r ~/.agentic-setup/skills/ ~/.agents/
```

**If skills are missing:**
```bash
# Check if the repository is fresh
$ ~/.agentic-setup/setup.sh --list-skills
$ ~/.agentic-setup/setup.sh --install-skill "missing-skill"
```

**If validation fails:**
```bash
# Run validation manually
$ scripts/validate.sh

# Fix any errors shown
```

## 📝 About This Project

This project provides a comprehensive, modular setup for the OMP coding agent harness. It automates the installation and configuration of all necessary components, making it easy to start using the harness on any compatible device.

### Key Features

- **Modular Skills**: Each skill is independent and can be installed individually
- **Automated Validation**: Comprehensive checks to ensure proper installation
- **Flexible Installation**: Different options to suit different needs
- **Documentation**: Complete, beautiful markdown documentation
- **Continuous Improvement**: Ideas for future enhancements

### Development Benefits

1. **Effortless Setup**: New devices are ready to use in minutes
2. **Selective Installation**: Install only the skills you need
3. **Easy Maintenance**: Clear separation of skills and rules
4. **Comprehensive Documentation**: Everything is well-documented
5. **Validation**: Always know if something is installed correctly

### Future Enhancements

- **Skill Publishing**: Easy way to share custom skills
- **Theme Support**: Customizable visual themes
- **Web Installer**: Web-based setup for different platforms
- **Integration**: Better integration with other tools and services

## 📚 Resources

### Documentation
- [AGENTS.md](AGENTS.md) - Core harness instructions
- [SETUP.MD](docs/SETUP.MD) - Device-specific setup guide
- [CONTRIBUTING.MD](docs/CONTRIBUTING.MD) - How to contribute
- [SKILL.md templates](skills/**/*.SKILL.md) - Skill templates

### Support
- [Repository](https://github.com/antoinelucasfra/agentic-setup) - Main repository
- [Issues](https://github.com/antoinelucasfra/agentic-setup/issues) - Bug reports and feature requests
- [Discussions](https://github.com/antoinelucasfra/agentic-setup/discussions) - Community discussions

## 🎁 Support This Project

This project aims to make the OMP coding agent harness accessible and easy to use. If you're finding it helpful:

1. **Star the repository** to show your support
2. **Share with others** who might benefit
3. **Contribute** your own skills and improvements
4. **Report issues** to help improve the project

### Special Thanks
This project was created to solve the problem of complex setup and configuration for the OMP coding agent harness, making it accessible to everyone with different skill levels and different devices.

---

*Created to simplify the OMP coding agent harness setup, one skill at a time.*