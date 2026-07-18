# 🎮 OMP Agentic Setup

This repository provides automated setup scripts and comprehensive documentation for the OMP coding agent harness across all platforms.

## 🎯 Project Goals and Scope

### Primary Goal
Create a comprehensive, automated setup system for the OMP (Oh My Pi) coding agent harness that enables developers to quickly install and configure the agent on any compatible device with minimal manual intervention.

### Scope Definition
This project focuses on:
- **Automated Installation**: Scripts that handle the entire setup process from cloning to validation
- **Cross-Platform Support**: Linux, macOS, and WSL2 environments
- **Skill Management**: Installation and organization of all OMP agent skills
- **Documentation**: Comprehensive guides for setup, usage, and contribution
- **Validation**: Built-in verification to ensure proper installation
- **Customization**: Options for selective skill installation and configuration

### Non-Goals
- ✘ GUI-based installation interfaces
- ✘ Windows native support (focus on WSL2/Linux/macOS)
- ✘ Enterprise deployment systems (SCCM, Intune, etc.)
- ✘ Mobile device installations
- ✘ Cloud provider specific configurations (AWS, Azure, GCP)

### Target Users
- Developers wanting to quickly start with OMP agent
- Teams needing standardized agent setup across environments
- Contributors adding new skills or updating existing ones
- System administrators managing multiple developer workstations

### Success Criteria
1. Single command installation (`./setup.sh`) works on target platforms
2. Validation script confirms proper installation of all components
3. Skills are correctly installed and accessible
4. Documentation is clear, complete, and actionable
5. CI pipeline validates the repository structure
6. Users can selectively install skills as needed
7. Uninstall process cleanly removes all components