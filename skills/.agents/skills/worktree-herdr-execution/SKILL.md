---
name: worktree-herdr-execution
description: Isolate changes with worktrunk (wt) and run commands or subagents in dedicated Herdr panes/tabs, discarding them on completion.
---

# Worktree & Herdr Execution Workflow

When working in Git repositories managed by AI agents, isolate features using **worktrunk** (`wt`) and run non-trivial commands or subagents inside dedicated **Herdr** panels.

## 1. Worktree Isolation with Worktrunk (`wt`)

Before performing code changes, multi-file refactors, or starting a subagent:

1. **Check for `wt` support**:
   ```bash
   command -v wt >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1
   ```
2. **Create / switch to an isolated worktree**:
   ```bash
   wt switch --create <feature-or-fix-slug>
   ```
   *Note*: Simple read-only inspections (`git status`, reading docs) remain in the current workspace.

3. **Cleanup when finished**:
   When work is complete and merged:
   ```bash
   wt remove
   ```

## 2. Dedicated Herdr Panes & Discard Policy

Never block the user's primary terminal with long-running commands, tests, or subagents.

1. **Spawn a background pane** without changing user focus:
   ```bash
   SPLIT_OUT=$(herdr pane split --current --direction right --cwd "$PWD" --no-focus)
   PANE_ID=$(echo "$SPLIT_OUT" | jq -r '.result.pane.pane_id')
   ```

2. **Execute command**:
   ```bash
   herdr pane run "$PANE_ID" "<command>"
   herdr pane wait-output "$PANE_ID" --regex ".*" --timeout 120000
   ```

3. **Inspect Output & Discard**:
   - Read output:
     ```bash
     herdr pane read "$PANE_ID" --source recent-unwrapped --lines 100
     ```
   - **On Success**: Immediately close and discard the pane to keep layout clean:
     ```bash
     herdr pane close "$PANE_ID"
     ```
   - **On Failure**: Keep the pane open so the user can inspect errors and logs interactively.
