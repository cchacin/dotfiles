#!/bin/sh

set -e

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

echo "==> Starting..."
cd "$HOME"
DOTFILES=${HOME}/dotfiles

if [ -d "${DOTFILES}" ]; then
  echo "==> Fetching  and Pulling latest dotfiles..."
  cd "${DOTFILES}" && git fetch > /dev/null && git pull > /dev/null
else
  echo "==> Cloning dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git
fi

UNAME=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
  # if homebrew exists install all the formulas
  if which brew > /dev/null; then
    echo "==> brew already installed..."
  else
    echo "==> Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  echo "==> Installing homebrew formulas"
  brew bundle install
fi

echo "==> Linking DotFiles to ${HOME}"
ln -s "${DOTFILES}"/.gitconfig "${HOME}"/.
ln -s "${DOTFILES}"/.ghci "${HOME}"/.
ln -s "${DOTFILES}"/.gitignore "${HOME}"/.
ln -s "${DOTFILES}"/.mavenrc "${HOME}"/.
ln -s "${DOTFILES}"/.p10k.zsh "${HOME}"/.
ln -s "${DOTFILES}"/.zlogin "${HOME}"/.
ln -s "${DOTFILES}"/.zprofile "${HOME}"/.
ln -s "${DOTFILES}"/.zshenv "${HOME}"/.
ln -s "${DOTFILES}"/.zshrc "${HOME}"/.
ln -s "${DOTFILES}"/.antigenrc "${HOME}"/.
ln -s "${DOTFILES}"/antigen.zsh "${HOME}"/.

echo "==> Done."
