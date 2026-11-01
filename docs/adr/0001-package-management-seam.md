# ADR 0001: Package Management Seam and Bootstrap Architecture

- **Status**: Accepted
- **Date**: 2026-10-31

## Context

Setting up a new machine requires installing both graphical desktop applications and a vast array of developer utilities, language runtimes, and terminal tools. Previously, package management responsibilities were blurred between Homebrew formulas and Mise packages, and `install.sh` lacked an autonomous bootstrap flow for installing missing package managers.

## Decision

1. **Package Management Seam**:
   - **Homebrew** (`brew/Brewfile`) is strictly responsible for macOS Base Primitives (`stow`, `git`, `mise`) and macOS GUI Casks (e.g., Ghostty, 1Password). Duplicative developer CLI formulas are deferred to Mise.
   - **Mise** (`mise/.config/mise/config.toml`) is exclusively responsible for all programming language runtimes, developer CLI tools, linters, terminal multiplexers, and AI agent CLIs.
2. **Autonomous Bootstrap (`install.sh`)**:
   - `install.sh` runs autonomously on new machines: installs Homebrew (if macOS and missing), installs Mise and Stow, links dotfile Stow packages, and runs `mise install && mise run setup:agent`.
3. **Local Overrides**:
   - Machine-specific and private configuration is decoupled via ignored `*.local` files (e.g., `~/.gitconfig.local`, `~/.zshrc.local`).

## Consequences

- Bootstrap on a blank macOS machine is a single command.
- Tool versions remain pinned and uniform across machines via Mise.
- Homebrew is kept fast and uncluttered from hundreds of formula dependency trees.
