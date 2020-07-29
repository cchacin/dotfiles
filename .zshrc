zmodload zsh/zprof

# Brew
export PATH="/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:$PATH"

# Brew curl
export PATH="/usr/local/opt/curl/bin:$PATH"

# Default user
DEFAULT_USER=ccchacin
BULLETTRAIN_CONTEXT_DEFAULT_USER=ccchacin

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

#Alias for Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

#Alias for maven
alias mver="mvn versions:display-dependency-updates versions:display-plugin-updates | grep 'INFO' | grep '>' | sort | uniq"

#Alias for cat
alias cat="bat --style=numbers,changes"

# JavaFX 11
export PATH_TO_FX=${HOME}/Downloads/javafx-sdk-11.0.2/lib

# python3
# alias python=/usr/local/bin/python3.7

# If there is cache available
if [[ -f ${HOME}/.antigen/.cache/.zcache-payload ]]; then
  # Load bundles statically
  source ${HOME}/.antigen/.cache/.zcache-payload

  # You will need to call compinit
  autoload -Uz compinstall compinit
  if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ${HOME}/.zcompdump) ]; then
    compinit -d ${HOME}/.zcompdump
  fi
  compinit -C
  # autoload -Uz compinit
  # compinit -d ${HOME}/.zcompdump
else
  # If there is no cache available do load and execute antigen
  source ${HOME}/antigen.zsh
  antigen init ${HOME}/dotfiles/.antigenrc > /dev/null 2>&1
  antigen cache-gen
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

source ~/dotfiles/private.sh || true
