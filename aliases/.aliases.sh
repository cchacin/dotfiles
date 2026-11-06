# shellcheck shell=bash
# Git
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

# Maven
mver() {
  mvn versions:display-dependency-updates \
      versions:display-plugin-updates \
      versions:display-property-updates \
      -Dmaven.version.ignore="(?i).*(alpha|beta|rc|cr|m[0-9]|preview|snapshot).*" \
      "$@" | awk '
    /^\[INFO\] The following (dependencies in .* have newer versions|plugin updates are available|version property updates are available|parent update)/ {
      in_updates = 1
      section = $0
      sub(/^\[INFO\] /, "", section)
      next
    }
    /^\[INFO\] *$/ || /^\[INFO\] [^ ]/ {
      in_updates = 0
    }
    in_updates && / -> / {
      line = $0
      sub(/^\[INFO\] +/, "  ", line)
      if (section != "") {
        print "\n" section
        section = ""
      }
      print line
      count++
    }
    END {
      if (count == 0) {
        print "All dependencies, plugins, and properties are up to date."
      }
    }
  '
}

# Add confirmation when removing files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vim=nvim
alias vi=nvim

zstyle ':omz:plugins:eza' 'git-status' yes

# Herdr 4-Tab Workspace (agent, shell, server, git)
hdev() {
  if ! command -v herdr >/dev/null 2>&1; then
    echo "Error: 'herdr' is required for hdev." >&2
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is required for hdev." >&2
    return 1
  fi
  local target_dir="${1:-$PWD}"
  target_dir="$(cd "$target_dir" 2>/dev/null && pwd || echo "$target_dir")"
  local label="${2:-$(basename "$target_dir")}"
  # Sanitize label for agent name: lowercase, letters/numbers/hyphen only
  local safe_label
  safe_label="$(echo "$label" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_-' '-' | sed 's/^-//;s/-$//')"
  local agent_name="omp-${safe_label:-agent}"

  # 1. Create the workspace (Tab 1 is created automatically as root)
  local ws_json
  ws_json="$(herdr workspace create --cwd "$target_dir" --label "$label" --focus)"
  local ws_id root_tab_id root_pane_id
  ws_id="$(echo "$ws_json" | jq -r '.result.workspace.workspace_id // empty')"
  root_tab_id="$(echo "$ws_json" | jq -r '.result.tab.tab_id // empty')"
  root_pane_id="$(echo "$ws_json" | jq -r '.result.root_pane.pane_id // empty')"

  if [ -z "$ws_id" ]; then
    echo "Error: Failed to create Herdr workspace." >&2
    return 1
  fi

  herdr workspace focus "$ws_id" >/dev/null 2>&1

  # Label Tab 1: agent
  herdr tab rename "$root_tab_id" "Lead Agent" >/dev/null 2>&1
  # Launch OMP in Tab 1
  herdr agent start "$agent_name" --kind omp --pane "$root_pane_id" --timeout 30000 &

  # 2. Create Tab 2: Sub Agents (2x2 grid with 4 Gemini flash-lite sub-agents)
  local tab2_json tab2_root_pane_id
  tab2_json="$(herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "Sub Agents" --no-focus)"
  tab2_root_pane_id="$(echo "$tab2_json" | jq -r '.result.root_pane.pane_id // empty')"

  if [ -n "$tab2_root_pane_id" ]; then
    local p2_id p3_id p4_id
    p2_id="$(herdr pane split --pane "$tab2_root_pane_id" --direction right --no-focus | jq -r '.result.pane.pane_id // empty')"
    p3_id="$(herdr pane split --pane "$tab2_root_pane_id" --direction down --no-focus | jq -r '.result.pane.pane_id // empty')"
    if [ -n "$p2_id" ]; then
      p4_id="$(herdr pane split --pane "$p2_id" --direction down --no-focus | jq -r '.result.pane.pane_id // empty')"
    fi

    [ -n "$tab2_root_pane_id" ] && herdr pane rename "$tab2_root_pane_id" "Performance" >/dev/null 2>&1
    [ -n "$p2_id" ] && herdr pane rename "$p2_id" "Bug" >/dev/null 2>&1
    [ -n "$p3_id" ] && herdr pane rename "$p3_id" "Architecture" >/dev/null 2>&1
    [ -n "$p4_id" ] && herdr pane rename "$p4_id" "Testing" >/dev/null 2>&1

    # Start all 5 agents (lead + 4 sub-agents) in parallel
    herdr agent start "${agent_name}-sub1" --kind omp --pane "$tab2_root_pane_id" --timeout 30000 -- --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files &
    [ -n "$p2_id" ] && herdr agent start "${agent_name}-sub2" --kind omp --pane "$p2_id" --timeout 30000 -- --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files &
    [ -n "$p3_id" ] && herdr agent start "${agent_name}-sub3" --kind omp --pane "$p3_id" --timeout 30000 -- --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files &
    [ -n "$p4_id" ] && herdr agent start "${agent_name}-sub4" --kind omp --pane "$p4_id" --timeout 30000 -- --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files &
    wait

    # Send idle/waiting prompts to each sub-agent in parallel
    herdr agent prompt "${agent_name}-sub1" "You are the Performance Sub-Agent. Your focus area is improving measurable performance bottlenecks. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." &
    [ -n "$p2_id" ] && herdr agent prompt "${agent_name}-sub2" "You are the Bug Sub-Agent. Your focus area is fixing real bugs affecting functionality normal usage, with no speculative edge-case hardening or bikeshedding. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." &
    [ -n "$p3_id" ] && herdr agent prompt "${agent_name}-sub3" "You are the Architecture Sub-Agent. Your focus area is simplifying architecture, removing duplication and unnecessary abstractions, preferring elegance and deletion over more machinery. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." &
    [ -n "$p4_id" ] && herdr agent prompt "${agent_name}-sub4" "You are the Testing Sub-Agent. Your focus area is focusing on a TDD approach to write and run test cases. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." &
  fi

  # Instruct Lead OMP Agent to utilize and delegate to the 4 sub-agents
  herdr agent prompt "$agent_name" "You are the Lead OMP Agent. You have 4 specialized sub-agents active in the 'Sub Agents' tab in a 2x2 layout:
- ${agent_name}-sub1 (top-left) [Performance]: Improve measurable performance bottlenecks.
- ${agent_name}-sub2 (top-right) [Bug]: Fix real bugs affecting functionality normal usage, no speculative edge-case hardening or bikeshedding.
- ${agent_name}-sub3 (bottom-left) [Architecture]: Simplify architecture, remove duplication and unnnecessary abstractions; prefer elegance and deletion over more machinery.
- ${agent_name}-sub4 (bottom-right) [Testing]: Focus on TDD approach to write and run test cases.
All sub-agents are running on gemini-2.5-flash-lite and are initialized in an IDLE state waiting for your delegation.
CRITICAL: DO NOT formulate plans or assign tasks to sub-agents yet. Acknowledge your role, enter an IDLE state, and WAIT for the human user to provide instructions, goals, or tasks before taking any action or delegating work." &
  wait

  # 3. Create Tab 3: server
  herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "Server" --no-focus >/dev/null 2>&1

  # 4. Create Tab 4: git (launch lazygit if installed)
  local tab4_json tab4_pane_id
  tab4_json="$(herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "Git" --no-focus)"
  tab4_pane_id="$(echo "$tab4_json" | jq -r '.result.root_pane.pane_id // empty')"

  if command -v lazygit >/dev/null 2>&1 && [ -n "$tab4_pane_id" ]; then
    herdr pane run "$tab4_pane_id" "lazygit" >/dev/null 2>&1
  fi

  # Focus back to workspace and Tab 1 (agent)
  herdr workspace focus "$ws_id" >/dev/null 2>&1
  herdr tab focus "$root_tab_id" >/dev/null 2>&1
  # If outside Herdr, attach to the TUI
  if [ "${HERDR_ENV:-}" != "1" ]; then
    herdr
  fi
}
alias h4=hdev
