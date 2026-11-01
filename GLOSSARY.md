# Dotfiles

Canonical vocabulary for this personal dotfiles environment, managing cross-machine configurations, package seams, and AI agent workspaces.

## Language

**Base Primitives**:
The foundational tools required to clone, link, and bootstrap the dotfiles environment (`git`, `stow`, `mise`, and on macOS, `Homebrew`).
_Avoid_: Core tools, prerequisites, system dependencies

**Cask**:
A macOS desktop application distributed through Homebrew Casks (e.g., Ghostty, 1Password, Slack), managed declaratively in `brew/Brewfile`.
_Avoid_: App, desktop package, GUI installer

**Brewfile**:
The declarative, single-source bundle specification containing all Homebrew formulas and casks, dumped and restored via `brew bundle`.
_Avoid_: Brew list, bundle manifest

**Local Override**:
An uncommitted, machine-specific configuration file (`~/.gitconfig.local`, `~/.zshrc.local`) sourced conditionally at the end of a tracked dotfile for environment-specific secrets, work identities, or custom PATH entries.
_Avoid_: Dotfile secret, private config, untracked patch

**Package Seam**:
The strict architectural boundary dividing package manager responsibilities: Homebrew manages Base Primitives and macOS Casks; Mise manages all language runtimes, developer CLI utilities, and AI agent extensions.
_Avoid_: Tooling split, package division

**Stow Package**:
A top-level directory in the dotfiles repository matching a configuration domain (e.g., `zsh/`, `git/`, `mise/`, `herdr/`) whose contents mirror `$HOME` and are symlinked via GNU Stow.
_Avoid_: Dotfile module, stow directory, config folder

**Target Collision**:
A condition during Stow linking where a pre-existing regular file or directory at the target destination (`$HOME`) blocks Stow from creating a symlink.
_Avoid_: Stow conflict, overwrite error, dirty state
