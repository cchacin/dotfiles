# If there is cache available
if [[ -f $HOME/.antigen/.cache/.zcache-payload ]]; then
    # Load bundles statically
    source $HOME/.antigen/.cache/.zcache-payload

    # You will need to call compinit
    # autoload -Uz compinit
    # compinit -d $HOME/.zcompdump
else
    # If there is no cache available do load and execute antigen
    source $HOME/.antigen.zsh

    # Load the oh-my-zsh's library.
    antigen use oh-my-zsh

    # Bundles from the default repo (robbyrussell's oh-my-zsh).
    antigen bundle ssh-agent
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
    antigen bundle gpg-agent
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
    antigen bundle zsh-syntax-highlighting

    # Load the theme.
    antigen theme caiogondim/bullet-train-oh-my-zsh-theme bullet-train

    # Tell antigen that you're done.
    antigen apply
fi

DEFAULT_USER=cchacin

# Brew
export PATH="/usr/local/sbin:$PATH"

#ALIAS for GIT
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gfm="git fetch; git merge origin/master"
alias gitfmp="git fetch; git merge origin/master --no-edit; ggpush master"

#Alias for Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

#Alias for maven
alias mver="mvn versions:display-dependency-updates versions:display-plugin-updates | grep 'INFO' | grep '>' | sort | uniq"
