#!/bin/sh

set -e

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

echo "==> 🚧 Starting..."
cd ~
DOTFILES=~/dotfiles

if [ -d "${DOTFILES}" ]; then
  echo "  ==> ✅ Dotfiles already present"
  echo "  ==> 🚧 Fetching and Pulling latest dotfiles..."
  cd "${DOTFILES}" && git pull origin master > /dev/null
else
  echo "  ==> 🚧 Cloning Dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git
  cd ${DOTFILES}
fi

cd ${DOTFILES}

echo "  ==> 🚧 Linking Dotfiles to ~..."
for filename in $(ls .);
do
  if [ -d "${filename}" ]; then
    stow -R ${filename}
    echo "    ==> ✅ Linked ${filename}"
  fi
done;

echo "==> ✅ Done."
