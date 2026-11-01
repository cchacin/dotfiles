# Agent Guidelines

Repository instructions for AI coding agents operating in this dotfiles repository.

## Architecture & Seams

- **Package Seam**: Homebrew manages Base Primitives (`stow`, `git`, `mise`) and macOS GUI Casks (`brew/Brewfile`). Mise exclusively manages all language runtimes, developer CLI tools, and agent CLIs (`mise/.config/mise/config.toml`). See `docs/adr/0001-package-management-seam.md`.
- **Symlinks (GNU Stow)**: Every top-level tool directory (e.g. `zsh/`, `git/`, `herdr/`, `mise/`) is a Stow package whose contents mirror `$HOME`.
- **Machine Overrides**: Machine-specific tokens, work emails, and custom PATHs belong in untracked `.local` files (`~/.gitconfig.local`, `~/.zshrc.local`). Never commit secrets or machine-local configs.
- **Agent Integration**: Herdr state extension (`~/.pi/agent/extensions/herdr-agent-state.ts`) and Agent Skills (`~/.agents/skills/`) are managed dynamically via `mise run setup:agent`. Never check generated skill files into dotfiles.

## Safe Changes & Validation

- **Worktree Isolation (`wt`)**: When `wt` is available and inside a git repository, isolate non-trivial changes, feature development, or subagents into a dedicated worktree (`wt switch --create <slug>`). Simple read-only operations stay in place. Clean up with `wt remove` once merged.
- **Herdr Execution & Pane Discard**: Run external tool commands, test suites, and subagents in a separate Herdr pane (`herdr pane split --current --direction right --no-focus`). On success, discard the pane immediately (`herdr pane close <id>`). On failure, retain the pane open for user inspection.
- **Shell scripts**: Every shell script must pass `shellcheck <script>` cleanly. Use `set -eu` and avoid parsing `ls`.
- **Pre-commit safety**: Verify `git status` before finishing turns. Ensure temporary files (`*.zwc`, `*.old`, `.scratch/`, `*.local`) remain untracked.

## Agent Skills & Workflows

### Issue Tracker

Issues, specs, and feature tasks live locally as Markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage Labels

Canonical triage roles mapped to status headers. See `docs/agents/triage-labels.md`.

### Domain Docs

Single-context documentation layout. Consult `GLOSSARY.md` for project vocabulary and `docs/adr/` for architectural decision records. See `docs/agents/domain.md`.
