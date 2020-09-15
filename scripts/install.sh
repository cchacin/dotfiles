#!/bin/sh

set -e

echo "      _       _      __ _ _"
echo "   __| | ___ | |_   / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|_| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||__|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__| |_| |_|_|\___||___/"
echo ""

echo "==> 🚧 Starting..."
cd "$HOME"
DOTFILES=${HOME}/dotfiles

if [ -d "${DOTFILES}" ]; then
  echo "  ==> ✅ Dotfiles already present"
  echo "  ==> 🚧 Fetching and Pulling latest dotfiles..."
  cd "${DOTFILES}" && git pull origin master > /dev/null
else
  echo "  ==> 🚧 Cloning Dotfiles..."
  git clone https://github.com/cchacin/dotfiles.git
  cd "${DOTFILES}"
fi

echo "  ==> 🚧 Linking Dotfiles to ${HOME}..."
for filename in $(ls -A ${DOTFILES}/files);
do
  ln -sf "${DOTFILES}/files/${filename}" "${HOME}"/.
  echo "    ==> ✅ Linked ${filename}";
done;

if [[ $OSTYPE == darwin* ]]; then
  echo "  ==> 🚧 Configuring MacOS..."
  if which brew > /dev/null; then
    echo "    ==> ✅ homebrew is already installed"
  else
    echo "    ==> 🚧 Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  echo "    ==> 🚧 Installing homebrew formulas"
  cd $HOME
  brew bundle install
fi

cd $DOTFILES
echo "==> ✅ Done."
