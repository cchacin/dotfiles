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

if command -v zstyle >/dev/null 2>&1; then
  zstyle ':omz:plugins:eza' 'git-status' yes
fi

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
  local raw_label
  raw_label="${2:-$(basename "$target_dir")}"
  # Sanitize workspace label: strip control chars & leading hyphens, cap to 128 chars
  local label
  label="$(printf '%s' "$raw_label" | LC_ALL=C tr -d '[:cntrl:]' | sed 's/^-*//' | cut -c1-128)"
  label="${label:-workspace}"
  # Sanitize label for Herdr agent name: ^[a-z][a-z0-9_-]{0,31}$
  # Reserve 18 chars for "omp-" (4) + "-" (1) + ws_suffix (<=8) + "-sub4" (5) => max 14 chars for safe_label
  local safe_label
  safe_label="$(printf '%s' "$label" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs 'a-z0-9_-' '-' | sed 's/^[-_]*//;s/[-_]*$//' | cut -c1-14 | sed 's/[-_]*$//')"
  local agent_name

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

  # Hex-encode ws_id so case-sensitive Herdr IDs (e.g. w2E vs w2e) stay lowercase [0-9a-f] without colliding
  local ws_suffix
  ws_suffix="$(printf '%s' "$ws_id" | od -An -tx1 | LC_ALL=C tr -d ' \t\n' | cut -c1-8)"
  ws_suffix="${ws_suffix:-$$}"
  ws_suffix="$(printf '%s' "$ws_suffix" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cd 'a-z0-9' | cut -c1-8)"
  ws_suffix="${ws_suffix:-0}"
  agent_name="omp-${safe_label:-agent}-${ws_suffix}"
  herdr workspace focus "$ws_id" >/dev/null 2>&1

  # Label Tab 1: agent
  herdr tab rename "$root_tab_id" "Lead Agent" >/dev/null 2>&1
  # Wait for root pane shell prompt to be ready
  herdr pane wait-output "$root_pane_id" --regex ".*" --timeout 5000 >/dev/null 2>&1 || sleep 1
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
    herdr agent prompt "${agent_name}-sub1" "You are the Performance Sub-Agent. Your focus area is improving measurable performance bottlenecks. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." && herdr agent send-keys "${agent_name}-sub1" Enter &
    [ -n "$p2_id" ] && herdr agent prompt "${agent_name}-sub2" "You are the Bug Sub-Agent. Your focus area is fixing real bugs affecting functionality normal usage, with no speculative edge-case hardening or bikeshedding. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." && herdr agent send-keys "${agent_name}-sub2" Enter &
    [ -n "$p3_id" ] && herdr agent prompt "${agent_name}-sub3" "You are the Architecture Sub-Agent. Your focus area is simplifying architecture, removing duplication and unnecessary abstractions, preferring elegance and deletion over more machinery. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." && herdr agent send-keys "${agent_name}-sub3" Enter &
    [ -n "$p4_id" ] && herdr agent prompt "${agent_name}-sub4" "You are the Testing Sub-Agent. Your focus area is focusing on a TDD approach to write and run test cases. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent." && herdr agent send-keys "${agent_name}-sub4" Enter &
  fi

  # Instruct Lead OMP Agent to utilize and delegate to the 4 sub-agents
  herdr agent prompt "$agent_name" "You are the Lead OMP Agent. You have 4 specialized sub-agents active in the 'Sub Agents' tab in a 2x2 layout:
- ${agent_name}-sub1 (top-left) [Performance]: Improve measurable performance bottlenecks.
- ${agent_name}-sub2 (top-right) [Bug]: Fix real bugs affecting functionality normal usage, no speculative edge-case hardening or bikeshedding.
- ${agent_name}-sub3 (bottom-left) [Architecture]: Simplify architecture, remove duplication and unnnecessary abstractions; prefer elegance and deletion over more machinery.
- ${agent_name}-sub4 (bottom-right) [Testing]: Focus on TDD approach to write and run test cases.
All sub-agents are running on gemini-2.5-flash-lite and are initialized in an IDLE state waiting for your delegation.
CRITICAL: You MUST ALWAYS delegate specific domain tasks (Performance, Bugs, Architecture, Testing) to your specialized sub-agents. Any background tasks, servers, or long-running processes you execute MUST be spawned in dedicated Herdr panes.
DO NOT formulate plans or assign tasks to sub-agents yet. Acknowledge your role, enter an idle state, and WAIT for the human user to provide instructions, goals, or tasks before taking any action or delegating work." && herdr agent send-keys "$agent_name" Enter &
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

# Rex 4-Tab Workspace (Lead Agent, Sub Agents, Server, Git)
rdev() {
  if [ -n "${REX_BIN_DIR:-}" ]; then
    case "$PATH" in
      "$REX_BIN_DIR" | "$REX_BIN_DIR:"*) ;;
      *) export PATH="$REX_BIN_DIR:$PATH" ;;
    esac
  elif ! command -v rex >/dev/null 2>&1; then
    local mac_rex_dir
    mac_rex_dir="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
    if [ -x "$mac_rex_dir/rex" ]; then
      export PATH="$mac_rex_dir:$PATH"
    fi
  fi

  if ! command -v rex >/dev/null 2>&1; then
    echo "Error: 'rex' is required for rdev." >&2
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is required for rdev." >&2
    return 1
  fi
  if ! command -v omp >/dev/null 2>&1; then
    echo "Error: 'omp' is required for rdev." >&2
    return 1
  fi

  local target_dir="${1:-$PWD}"
  target_dir="$(cd "$target_dir" 2>/dev/null && pwd || echo "$target_dir")"
  local raw_label
  raw_label="${2:-$(basename "$target_dir")}"
  # Sanitize Rex session label: strip control chars & leading hyphens (flag ambiguity), cap to 128 chars
  local label
  label="$(printf '%s' "$raw_label" | LC_ALL=C tr -d '[:cntrl:]' | sed 's/^-*//' | cut -c1-128)"
  label="${label:-workspace}"

  local sub1_prompt="You are the Performance Sub-Agent. Your focus area is improving measurable performance bottlenecks. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent."
  local sub2_prompt="You are the Bug Sub-Agent. Your focus area is fixing real bugs affecting functionality normal usage, with no speculative edge-case hardening or bikeshedding. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent."
  local sub3_prompt="You are the Architecture Sub-Agent. Your focus area is simplifying architecture, removing duplication and unnecessary abstractions, preferring elegance and deletion over more machinery. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent."
  local sub4_prompt="You are the Testing Sub-Agent. Your focus area is focusing on a TDD approach to write and run test cases. DO NOT make any edits or start working yet. Acknowledge your role, enter an idle state, and wait for explicit task delegation from the Lead Agent."

  # 1. Create the Rex session starting with Sub Agents (2x2 grid with 4 Gemini flash-lite sub-agents)
  local ws_json ws_id p1_id p2_id="" p3_id="" p4_id=""
  if ! ws_json="$(rex new "$label" -c "$target_dir" --window "Sub Agents" --interactive --keep-open --json -- \
    omp --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files --no-title "$sub1_prompt")"; then
    echo "Error: Failed to create Rex session." >&2
    return 1
  fi
  ws_id="$(printf '%s' "$ws_json" | jq -r '.session_id // empty')"
  p1_id="$(printf '%s' "$ws_json" | jq -r '.initial_windows[0].block_ids[0] // empty')"

  if [ -z "$ws_id" ]; then
    echo "Error: Failed to create Rex session." >&2
    return 1
  fi

  if [ -n "$p1_id" ]; then
    rex block rename -s "$ws_id" "$p1_id" "Performance" >/dev/null 2>&1

    p2_id="$(rex split -s "$ws_id" -b "$p1_id" --split=right -c "$target_dir" --label "Bug" --focus=false --interactive --keep-open --json -- \
      omp --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files --no-title "$sub2_prompt" | jq -r '.block_ids[0] // empty')"

    p3_id="$(rex split -s "$ws_id" -b "$p1_id" --split=below -c "$target_dir" --label "Architecture" --focus=false --interactive --keep-open --json -- \
      omp --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files --no-title "$sub3_prompt" | jq -r '.block_ids[0] // empty')"

    if [ -n "$p2_id" ]; then
      p4_id="$(rex split -s "$ws_id" -b "$p2_id" --split=below -c "$target_dir" --label "Testing" --focus=false --interactive --keep-open --json -- \
        omp --model gemini-2.5-flash-lite --tools=read,grep,glob --no-context-files --no-title "$sub4_prompt" | jq -r '.block_ids[0] // empty')"
    fi
  fi

  # 2. Create Tab 1: Lead Agent (with exact Sub-Agent block IDs) and move to index 1
  local lead_prompt="You are the Lead OMP Agent in Rex session ${ws_id}. You have 4 specialized sub-agents active in the 'Sub Agents' tab in a 2x2 layout:
- ${p1_id:-Performance} (top-left) [Performance]: Improve measurable performance bottlenecks.
- ${p2_id:-Bug} (top-right) [Bug]: Fix real bugs affecting functionality normal usage, no speculative edge-case hardening or bikeshedding.
- ${p3_id:-Architecture} (bottom-left) [Architecture]: Simplify architecture, remove duplication and unnecessary abstractions; prefer elegance and deletion over more machinery.
- ${p4_id:-Testing} (bottom-right) [Testing]: Focus on TDD approach to write and run test cases.
All sub-agents are running on gemini-2.5-flash-lite and are initialized in an IDLE state waiting for your delegation.
To delegate a task to a sub-agent, send instructions to its block with:
  rex send -s \"${ws_id}\" -b \"<block_id>\" \"<task>\" && rex send-key -s \"${ws_id}\" -b \"<block_id>\" enter
To read a sub-agent's output, run:
  rex capture -s \"${ws_id}\" -b \"<block_id>\" --trim
CRITICAL: You MUST ALWAYS delegate specific domain tasks (Performance, Bugs, Architecture, Testing) to your specialized sub-agents. Any background tasks, servers, or long-running processes you execute MUST be spawned in dedicated Rex panes/tabs (e.g., via 'rex split' or 'rex window new').
DO NOT formulate plans or assign tasks to sub-agents yet. Acknowledge your role, enter an idle state, and WAIT for the human user to provide instructions, goals, or tasks before taking any action or delegating work."

  local lead_json root_tab_id root_pane_id
  lead_json="$(rex window new -s "$ws_id" "Lead Agent" -c "$target_dir" --interactive --keep-open --json -- \
    omp --no-title "$lead_prompt")"
  root_tab_id="$(printf '%s' "$lead_json" | jq -r '.window_id // empty')"
  root_pane_id="$(printf '%s' "$lead_json" | jq -r '.block_ids[0] // empty')"

  if [ -n "$root_tab_id" ]; then
    rex window move -s "$ws_id" "$root_tab_id" --index 1 >/dev/null 2>&1
  fi
  if [ -n "$root_pane_id" ]; then
    rex block rename -s "$ws_id" "$root_pane_id" "Lead Agent" >/dev/null 2>&1
  fi

  # 3. Create Tab 3: Server
  rex window new -s "$ws_id" "Server" -c "$target_dir" --focus=false --json >/dev/null 2>&1

  # 4. Create Tab 4: Git (launch lazygit if installed)
  local tab4_json tab4_pane_id
  tab4_json="$(rex window new -s "$ws_id" "Git" -c "$target_dir" --focus=false --json)"
  tab4_pane_id="$(printf '%s' "$tab4_json" | jq -r '.block_ids[0] // empty')"

  if command -v lazygit >/dev/null 2>&1 && [ -n "$tab4_pane_id" ]; then
    rex send -s "$ws_id" -b "$tab4_pane_id" "lazygit" >/dev/null 2>&1 && \
      rex send-key -s "$ws_id" -b "$tab4_pane_id" enter >/dev/null 2>&1
  fi

  # Focus back to Tab 1 (Lead Agent) and select the session in Rex app
  if [ -n "$root_pane_id" ]; then
    rex focus -s "$ws_id" "$root_pane_id" >/dev/null 2>&1
  elif [ -n "$root_tab_id" ]; then
    rex window focus -s "$ws_id" "$root_tab_id" >/dev/null 2>&1
  fi

  echo "Created Rex session '$label' ($ws_id) with 4 tabs (Lead Agent, Sub Agents, Server, Git)."

  local select_err
  if [ -n "$root_tab_id" ]; then
    if ! select_err="$(rex "do" session.select "session_id=$ws_id" "window_id=$root_tab_id" 2>&1 >/dev/null)"; then
      [ -n "$select_err" ] && echo "$select_err" >&2
      echo "Tip: Press Cmd+K (Change Session) or Cmd+/ (Sidebar) to open '$label', or turn on Remote Control in Rex Settings (Cmd+, -> Rex Server) to auto-switch." >&2
    fi
  else
    if ! select_err="$(rex "do" session.select "session_id=$ws_id" 2>&1 >/dev/null)"; then
      [ -n "$select_err" ] && echo "$select_err" >&2
      echo "Tip: Press Cmd+K (Change Session) or Cmd+/ (Sidebar) to open '$label', or turn on Remote Control in Rex Settings (Cmd+, -> Rex Server) to auto-switch." >&2
    fi
  fi

  if [ -z "${REX_SESSION:-}" ] && [ "$(uname -s)" = "Darwin" ]; then
    open -a "Rex" >/dev/null 2>&1 || open -a "Rex Beta" >/dev/null 2>&1 || true
  fi
}
alias r4=rdev
