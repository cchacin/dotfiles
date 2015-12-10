#!/bin/sh

set -e

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

echo "==> Starting..."
cd ~

if [ -d dotfiles ]; then
  echo "==> Fetching  and Pulling latest dotfiles..."
  cd ~/dotfiles && git fetch > /dev/null && git pull > /dev/null
else
  echo "==> Cloning dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git
  echo "==> Updating all git submodules..."
  cd ~/dotfiles && git submodule update --init --recursive > /dev/null
fi


# if homebrew exists install all the formulas in homebrew.txt
if which brew > /dev/null; then
  echo "==> brew already installed..."
else
  echo "==> Installing homebrew"
  if which ruby > /dev/null; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    echo "==> skipping brew installation ruby is not installed in your system"
  fi
fi

if which brew > /dev/null; then
  echo "==> Installing homebrew formulas"
  cat brew.txt | xargs brew install
  cat brewcask.txt | xargs brew cask install
fi

echo "==> Done."
