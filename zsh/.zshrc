# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_DOWNLOAD_CONCURRENCY=auto
export PATH="${HOME}/.local/bin:${PATH}"

# Antidote plugin bundle (loads plugins including mroth/evalcache)
source "$HOME/.antidote"

# Initialize completion system if not already initialized
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

# Initialize zoxide (cached via evalcache if available)
if type _evalcache >/dev/null 2>&1; then
  _evalcache zoxide init zsh --cmd cd
elif command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if [[ -f "$HOME/.aliases.sh" ]]; then
  source "$HOME/.aliases.sh"
fi

if [[ -f "$HOME/.private.sh" ]]; then
  source "$HOME/.private.sh"
fi

# BEGIN opam configuration
[[ ! -r "${HOME}/.opam/opam-init/init.zsh" ]] || source "${HOME}/.opam/opam-init/init.zsh" > /dev/null 2>&1
# END opam configuration

# 1Password CLI completion
if command -v op >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op 2>/dev/null || true
fi

# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  fpath+=("${HOME}/.local/share/zsh/site-functions")
fi

# Herdr & Zsh integration (handled dynamically by robbyrussell/herdr-ohmyzsh)
export HERDR_OMZ_DEFAULT_AGENT="pi"
export HERDR_OMZ_THRESHOLD=10

# Local machine overrides
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
