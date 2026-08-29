# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

export HOMEBREW_NO_AUTO_UPDATE=1

source $HOME/.antidote

_evalcache zoxide init zsh --cmd cd

if [[ -f $HOME/.aliases.sh ]]; then
  source $HOME/.aliases.sh
fi

if [[ -f $HOME/.private.sh ]]; then
  source $HOME/.private.sh
fi

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
