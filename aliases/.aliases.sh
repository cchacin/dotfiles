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
  local target_dir="${1:-$PWD}"
  target_dir="$(cd "$target_dir" 2>/dev/null && pwd || echo "$target_dir")"
  local label="${2:-$(basename "$target_dir")}"
  # Sanitize label for agent name: lowercase, letters/numbers/hyphen only
  local safe_label
  safe_label="$(echo "$label" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_-' '-' | sed 's/^-//;s/-$//')"
  local agent_name="pi-${safe_label:-agent}"

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

  # Label Tab 1: agent
  herdr tab rename "$root_tab_id" "agent" >/dev/null 2>&1

  # Launch Pi in Tab 1
  herdr agent start "$agent_name" --kind pi --pane "$root_pane_id" >/dev/null 2>&1 &

  # 2. Create Tab 2: shell
  herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "shell" --no-focus >/dev/null 2>&1

  # 3. Create Tab 3: server
  herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "server" --no-focus >/dev/null 2>&1

  # 4. Create Tab 4: git (launch lazygit if installed)
  local tab4_json tab4_pane_id
  tab4_json="$(herdr tab create --workspace "$ws_id" --cwd "$target_dir" --label "git" --no-focus)"
  tab4_pane_id="$(echo "$tab4_json" | jq -r '.result.root_pane.pane_id // empty')"

  if command -v lazygit >/dev/null 2>&1 && [ -n "$tab4_pane_id" ]; then
    herdr pane run "$tab4_pane_id" "lazygit" >/dev/null 2>&1
  fi

  # Focus back to Tab 1 (agent)
  herdr tab focus "$root_tab_id" >/dev/null 2>&1

  # If outside Herdr, attach to the TUI
  if [ "${HERDR_ENV:-}" != "1" ]; then
    herdr
  fi
}
alias h4=hdev
