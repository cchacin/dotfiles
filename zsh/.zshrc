# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ANTIGEN_CACHE=$HOME/.cache/antigen

zmodload zsh/zprof

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

if [[ -f $HOME/.aliases.sh ]]; then
  source $HOME/.aliases.sh
fi

if [[ -f $HOME/.private.sh ]]; then
  source $HOME/.private.sh
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/cchacin/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/cchacin/.opam/opam-init/init.zsh' ]] || source '/Users/cchacin/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
export HOMEBREW_DOWNLOAD_CONCURRENCY=auto
export PATH="/Users/cchacin/.local/bin:$PATH"
eval "$(zoxide init zsh --cmd cd)"

# AsyncAPI CLI Autocomplete

ASYNCAPI_AC_ZSH_SETUP_PATH=/Users/cchacin/Library/Caches/@asyncapi/cli/autocomplete/zsh_setup && test -f $ASYNCAPI_AC_ZSH_SETUP_PATH && source $ASYNCAPI_AC_ZSH_SETUP_PATH; # asyncapi autocomplete setup


