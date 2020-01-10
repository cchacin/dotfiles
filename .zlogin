(
    # <https://github.com/zimfw/zimfw/blob/master/login_init.zsh>
    setopt LOCAL_OPTIONS EXTENDED_GLOB
    autoload -U zrecompile
    local ZSHCONFIG=~/dotfiles

    # Compile zcompdump, if modified, to increase startup speed.
    zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
        zrecompile -pq "$zcompdump"
    fi
    # zcompile .zshrc
    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zshrc
    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zprofile
    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zshenv
    # recompile all zsh or sh
    for f in $ZSHCONFIG/**/*.*sh
    do
        # zrecompile -pq $f
    done
) &!

# If there is cache available
if [[ -f ${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload ]]; then
  # Load bundles statically
  source ${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload

  # You will need to call compinit
  autoload -Uz compinstall compinit
  if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
    compinit -d ${HOME}/.zcompdump
  fi
  compinit -C
  # autoload -Uz compinit
  # compinit -d ${HOME}/.zcompdump
else
  # If there is no cache available do load and execute antigen
  source $HOME/dotfiles/antigen/bin/antigen.zsh
  antigen init $HOME/dotfiles/.antigenrc > /dev/null 2>&1
  antigen cache-gen
fi
