#!/bin/sh
set -eu

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

should_skip_pkg() {
  case "$1" in
    .git|.github|docs|scripts) return 0 ;;
    *) return 1 ;;
  esac
}

echo "==> 🚧 Starting dotfiles bootstrap..."

DOTFILES="${HOME}/dotfiles"

# 1. Ensure Homebrew is installed on macOS
if [ "$(uname)" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "  ==> 🚧 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d "/opt/homebrew/bin" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  # Install dependencies via Homebrew
  if [ -f "${DOTFILES}/brew/Brewfile" ]; then
    echo "  ==> 🚧 Running Brewfile..."
    brew bundle --file="${DOTFILES}/brew/Brewfile" || true
  fi
fi

# 2. Ensure Mise is installed
if ! command -v mise >/dev/null 2>&1; then
  echo "  ==> 🚧 Installing mise..."
  curl https://mise.run | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

# 3. Ensure Stow is available
if ! command -v stow >/dev/null 2>&1; then
  echo "  ==> ❌ Error: 'stow' is required but not installed." >&2
  exit 1
fi

# 4. Clone or update repository
if [ -d "${DOTFILES}" ]; then
  echo "  ==> ✅ Dotfiles already present"
  echo "  ==> 🚧 Fetching and pulling latest changes..."
  git -C "${DOTFILES}" pull --ff-only > /dev/null 2>&1 || true
else
  echo "  ==> 🚧 Cloning Dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git "${DOTFILES}"
fi

cd "${DOTFILES}"

# 5. Collision backup: Back up non-symlink target files that would block stow
BACKUP_DIR="${HOME}/.dotfiles.backup.$(date +%Y%m%d%H%M%S)"
BACKUP_FLAG_FILE="$(mktemp)"

# Single find pass across packages to reduce process overhead
find . -mindepth 2 -type f \
  ! -path './.git*' \
  ! -path './.github*' \
  ! -path './docs*' \
  ! -path './scripts*' | while IFS= read -r src_file; do
    clean_path="${src_file#./}"
    pkg="${clean_path%%/*}"
    rel_path="${clean_path#*/}"
    target_file="${HOME}/${rel_path}"

    if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
      if [ ! -f "$BACKUP_FLAG_FILE" ] || [ "$(cat "$BACKUP_FLAG_FILE")" != "1" ]; then
        echo "  ==> ⚠️  Target collision detected. Backing up existing files to ${BACKUP_DIR}..."
        mkdir -p "${BACKUP_DIR}"
        echo "1" > "$BACKUP_FLAG_FILE"
      fi
      mkdir -p "$(dirname "${BACKUP_DIR}/${rel_path}")"
      mv "$target_file" "${BACKUP_DIR}/${rel_path}"
      echo "    ==> Backed up ${rel_path}"
    fi
  done
rm -f "$BACKUP_FLAG_FILE"

# 6. Link packages using Stow (parallel with exit status validation)
echo "  ==> 🚧 Linking Dotfiles to ~ (parallel)..."
pids=""
for dir in */; do
  pkg="${dir%/}"
  if should_skip_pkg "$pkg"; then
    continue
  fi
  (stow -R "$pkg" && echo "    ==> ✅ Linked ${pkg}") &
  pids="$pids $!"
done

stow_failed=0
for pid in $pids; do
  wait "$pid" || stow_failed=1
done

if [ "$stow_failed" -eq 1 ]; then
  echo "  ==> ❌ Error: One or more packages failed to link with stow." >&2
  exit 1
fi

# 7. Install developer tools and agent setup via Mise
if command -v mise >/dev/null 2>&1; then
  echo "  ==> 🚧 Installing tools via mise..."
  mise install
  echo "  ==> 🚧 Setting up agent environment (Herdr + Pi + skills)..."
  mise run setup:agent
fi

# 8. Set default login shell to Homebrew Zsh on macOS (if available) or system zsh
if [ "$(uname)" = "Darwin" ] && [ -x "/opt/homebrew/bin/zsh" ]; then
  BREW_ZSH="/opt/homebrew/bin/zsh"
  if ! grep -qxF "$BREW_ZSH" /etc/shells 2>/dev/null; then
    echo "  ==> ℹ️  Note: To set Homebrew Zsh as default login shell, run:"
    echo "      echo '$BREW_ZSH' | sudo tee -a /etc/shells && chsh -s '$BREW_ZSH'"
  elif [ "${SHELL:-}" != "$BREW_ZSH" ]; then
    echo "  ==> 🚧 Setting login shell to ${BREW_ZSH}..."
    chsh -s "$BREW_ZSH" 2>/dev/null || true
  fi
elif command -v zsh >/dev/null 2>&1; then
  ZSH_PATH="$(command -v zsh)"
  if [ "${SHELL:-}" != "$ZSH_PATH" ] && [ "$(uname)" = "Darwin" ]; then
    echo "  ==> 🚧 Setting default shell to ${ZSH_PATH}..."
    chsh -s "$ZSH_PATH" 2>/dev/null || true
  fi
fi

echo "==> ✅ Bootstrap completed successfully."
