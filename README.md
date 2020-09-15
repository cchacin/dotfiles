# dotfiles

![Dotfiles Installation gif](DotfilesInstallation.gif)

## What's in there

### OhMyZsh

[OhMyZsh](https://ohmyz.sh/) configured using [Antigen](https://antigen.sharats.me/) and [powerlevel10k](https://github.com/romkatv/powerlevel10k) theme:

![prompt style image](prompt-style.png)

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

[Homebrew](https://brew.sh/) formulas and casks installed and backed up in a bundle: `Brewfile`

- `brew bundle install` to install all the formulas and casks
- `brew bundle dump -f` to regenerate the `Brewfile`

### Git
- Global `.gitconfig`
- Global `.gitignore`

### Java
- JDKs installed with Hombrew
- [jEnv](https://www.jenv.be/) installed with Hombrew
- Global `.mavenrc` using [jEnv](https://www.jenv.be/)

## How to install:
```sh
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/cchacin/dotfiles/master/scripts/install.sh)"
```
