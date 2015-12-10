# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(atom autojump brew brew-cask bundler capistrano colored-man-pages common-aliases composer docker docker-compose gem git git-extras git-flow gitignore gpg-agent gradle heroku history httpie mvn node npm rbenv redis-cli ruby sbt scala ssh-agent sublime sudo svn symfony2 vagrant z zsh_reload zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

DEFAULT_USER=cchacin

export PATH="/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin"
# export MANPATH="/usr/local/man:$MANPATH"

# # Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

#ALIAS for GIT
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gfm="git fetch; git merge origin/master"
alias gitfmp="git fetch; git merge origin/master --no-edit; ggpush master"

#Alias for Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

# ondir configuration
cd() {
  builtin cd "$@" && eval "`ondir \"$OLDPWD\" \"$PWD\"`"
}
pushd() {
  builtin pushd "$@" && eval "`ondir \"$OLDPWD\" \"$PWD\"`"
}
popd() {
  builtin popd "$@" && eval "`ondir \"$OLDPWD\" \"$PWD\"`"
}
eval "`ondir /`"

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=/usr/local/sbin:$PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Maven
export M2_HOME=/usr/local/Cellar/maven/3.3.9/libexec
