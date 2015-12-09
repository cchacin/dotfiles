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
# if repo doesn't exists then clone
echo "==> Cloning dotfiles..."
git clone https://github.com/cchacin/dotfiles.git

# else fetch & pull
echo "==> Fetching  and Pulling latest dotfiles..."
git fetch &> /dev/null
git pull &> /dev/null

echo "  > Updating all git submodules..."
git submodule init &> /dev/null
git submodule update &> /dev/null

# if homebrew exists install all the formulas in homebrew.txt
if [] then
echo "Installing homebrew formulas"
cat brew.txt | xargs brew install
cat brewcasks.txt | xargs brew cask install
fi


echo "==> Done."
