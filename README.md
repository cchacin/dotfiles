# dotfiles

## What's in there

### OhMyZsh

Configured using [antigen]() and [powerlevel10k]() theme

OhMyZSH Plugins:

- ssh-agent
- gpg-agent
- autojump
- brew
- brew-cask
- colored-man-pages
- common-aliases
- docker
- docker-compose
- git
- git-extras
- git-hubflow
- git-remote-branch
- gitignore
- heroku
- history
- httpie
- mvn
- sudo
- rbenv
- jenv
- zsh-users/zsh-syntax-highlighting

### Homebrew

Homebrew formulas and casks installed and backed up in a bundle: `Brewfile`

- `brew bundle install` to install all the formulas and casks
- `brew bundle dump -f` to regenerate the `Brewfile`

### Git
- Global `.gitconfig`
- Global `.gitignore`

### Java
- JDKs installed with Hombrew
- [jEnv]() installed with Hombrew
- Global `.mavenrc` using [jEnv]()

## How to install:
```sh
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/cchacin/dotfiles/master/scripts/install.sh)"
```
