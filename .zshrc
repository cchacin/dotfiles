# Brew
export PATH="/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:$PATH"
export PATH="$PATH:/Users/cchacin/istio-1.0.0/bin"
# export PATH="/usr/local/sbin:$PATH"

# Brew curl
export PATH="/usr/local/opt/curl/bin:$PATH"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export TERM="xterm-256color"

# Default user
DEFAULT_USER=cchacin
BULLETTRAIN_CONTEXT_DEFAULT_USER=cchacin

# # JENV
if [ ! -n "${BULLETTRAIN_JENV_BG+1}" ]; then
  BULLETTRAIN_JENV_BG=black
fi
if [ ! -n "${BULLETTRAIN_JENV_FG+1}" ]; then
  BULLETTRAIN_JENV_FG=white
fi
if [ ! -n "${BULLETTRAIN_JENV_PREFIX+1}" ]; then
  BULLETTRAIN_JENV_PREFIX="\u2615 "
fi

# JENV: Java version manager
prompt_jenv() {
  local jenv_prompt
  if $(jenv >/dev/null 2>&1); then
    jenv_prompt="$(jenv version-name)"
    prompt_segment $BULLETTRAIN_JENV_BG $BULLETTRAIN_JENV_FG $BULLETTRAIN_JENV_PREFIX$jenv_prompt
  fi
}
  BULLETTRAIN_PROMPT_ORDER=(
    time
    status
    custom
    context
    dir
    perl
    ruby
    virtualenv
    jenv
    go
    elixir
    git
    hg
    cmd_exec_time
  )

# SSH
export SSH_KEY_PATH="$HOME/.ssh"

#ALIAS for GIT
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gfm="git fetch; git merge origin/master"
alias gitfmp="git fetch; git merge origin/master --no-edit; ggpush master"

#Alias for Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

#Alias for maven
alias mver="mvn versions:display-dependency-updates versions:display-plugin-updates | grep 'INFO' | grep '>' | sort | uniq"

#Alias for cat
alias cat="bat --style=numbers,changes"

# You will need to call compinit
autoload -U compinstall
autoload -Uz compinit
compinit -d $HOME/.zcompdump

#rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# If there is cache available
if [[ -f $HOME/.antigen/.cache/.zcache-payload ]]; then
    # Load bundles statically
    source $HOME/.antigen/.cache/.zcache-payload
else
    # If there is no cache available do load and execute antigen
    source $HOME/.antigen.zsh

    # Load the oh-my-zsh's library.
    antigen use oh-my-zsh

    # Bundles from the default repo (robbyrussell's oh-my-zsh).
    antigen bundle ssh-agent
    antigen bundle gpg-agent
    antigen bundle autojump
    antigen bundle brew
    antigen bundle brew-cask
    antigen bundle bundler
    antigen bundle capistrano
    antigen bundle colored-man-pages
    antigen bundle common-aliases
    antigen bundle docker
    antigen bundle docker-compose
    antigen bundle gem
    antigen bundle git
    antigen bundle git-extras
    antigen bundle git-hubflow
    antigen bundle git-remote-branch
    antigen bundle gitignore
    antigen bundle gradle
    antigen bundle heroku
    antigen bundle history
    antigen bundle httpie
    antigen bundle mvn
    antigen bundle rbenv
    antigen bundle redis-cli
    antigen bundle ruby
    antigen bundle sudo
    antigen bundle zsh_reload
    antigen bundle zsh-users/zsh-syntax-highlighting

    # Load the theme.
    # antigen theme robbyrussell/oh-my-zsh themes/avit
    antigen theme caiogondim/bullet-train-oh-my-zsh-theme bullet-train

    # Tell antigen that you're done.
    antigen apply
fi

export JAVA_HOME=$(jenv javahome)
# export JAVA_HOME="`/usr/libexec/java_home -v '1.8*'`"

# List of accounts to read the last tweet from, comma separated
# The first in the list is read by the party parrot.
export TTC_BOTS='tinycarebot,selfcare_bot,magicrealismbot'

# Use this to have a different animal say a message in the big box.
export TTC_SAY_BOX='mario'

# List of folders to look into for `git` commits, comma separated.
export TTC_REPOS='~/Git/MicroGen'

# The max directory-depth to look for git repositories in
# the directories defined with `TTC_REPOS`. Note that the deeper
# the directory depth, the slower the results will be fetched.
export TTC_REPOS_DEPTH=1

# Location/zip code to check the weather for. Both 90210 and "San Francisco, CA"
# _should_ be ok (the zip code doesn't always work -- use a location
# first, if you can). It's using weather.service.msn.com behind the curtains.
export TTC_WEATHER='Seattle'

# Set to false if you're an imperial lover <3
export TTC_CELSIUS=true

# Unset this if you _don't_ want to use Twitter keys and want to
# use web scraping instead.
export TTC_APIKEYS=false

# Refresh the dashboard every 20 minutes.
export TTC_UPDATE_INTERVAL=20

# Turn off terminal title
export TTC_TERMINAL_TITLE=false

# Twitter api keys
export TTC_CONSUMER_KEY='...'
export TTC_CONSUMER_SECRET='...'
export TTC_ACCESS_TOKEN='...'
export TTC_ACCESS_TOKEN_SECRET='...'

# Note: in tiny-terminal-care < 1.0.7, the recommended variables for the Twitter
# API keys were the ones before. As of 1.0.8, they are deprecated
# (because the names are too generic), but will still be supported
# until the next major version.
export CONSUMER_KEY='...'
export CONSUMER_SECRET='...'
export ACCESS_TOKEN='...'
export ACCESS_TOKEN_SECRET='...'

# Default pomodoro is 20 minutes and default break is 5 minutes.
# You can change these defaults like this.
export TTC_POMODORO=20
export TTC_BREAK=5

# JavaFX 11
export PATH_TO_FX=~/Downloads/javafx-sdk-11.0.2/lib
