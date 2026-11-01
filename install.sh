#!/bin/sh
set -eu

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

echo "==> 🚧 Starting..."

DOTFILES="${HOME}/dotfiles"

# Check required base tools
for cmd in git stow; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "==> ❌ Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

if [ -d "${DOTFILES}" ]; then
  echo "  ==> ✅ Dotfiles already present"
  echo "  ==> 🚧 Fetching and pulling latest changes..."
  git -C "${DOTFILES}" pull --ff-only > /dev/null 2>&1 || true
else
  echo "  ==> 🚧 Cloning Dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git "${DOTFILES}"
fi

cd "${DOTFILES}"

echo "  ==> 🚧 Linking Dotfiles to ~..."
for dir in */; do
  pkg="${dir%/}"
  case "$pkg" in
    .git|.github|docs|scripts) continue ;;
  esac
  stow -R "$pkg"
  echo "    ==> ✅ Linked ${pkg}"
done

if command -v mise >/dev/null 2>&1; then
  echo "  ==> 🚧 Installing tools via mise..."
  mise install
  echo "  ==> 🚧 Setting up agent environment (Herdr + Pi + skills)..."
  mise run setup:agent
fi

echo "==> ✅ Done."
