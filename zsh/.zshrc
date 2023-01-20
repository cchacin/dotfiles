# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ANTIGEN_CACHE=$HOME/.cache/antigen

zmodload zsh/zprof

if [[ -f $HOME/.aliases.sh ]]; then
  source $HOME/.aliases.sh
fi

if [[ -f $HOME/.private.sh ]]; then
  source $HOME/.private.sh
fi


# If there is cache available
if [[ -f $ANTIGEN_CACHE ]]; then
  # Load bundles statically
  source $ANTIGEN_CACHE

  # You will need to call compinit
  autoload -Uz compinstall compinit
  if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' $HOME/.zcompdump) ]; then
    compinit -d $HOME/.zcompdump
  fi
  compinit -C
else
  # If there is no cache available do load and execute antigen
  source $HOME/antigen.zsh
  antigen init $HOME/.antigenrc > /dev/null 2>&1
  antigen cache-gen
fi

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# Add Jbang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"

# Haskell GHCUP
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

if [[ -f /usr/local/opt/asdf/libexec/asdf.sh ]]; then
  . /usr/local/opt/asdf/libexec/asdf.sh
fi
