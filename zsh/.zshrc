# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zmodload zsh/zprof

if [[ -f ~/.aliases.sh ]]; then
  source ~/.aliases.sh
fi

if [[ -f ~/.private.sh ]]; then
  source ~/.private.sh
fi


# If there is cache available
if [[ -f ~/.antigen/.cache/.zcache-payload ]]; then
  # Load bundles statically
  source ~/.antigen/.cache/.zcache-payload

  # You will need to call compinit
  autoload -Uz compinstall compinit
  if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
    compinit -d ~/.zcompdump
  fi
  compinit -C
else
  # If there is no cache available do load and execute antigen
  source ~/antigen.zsh
  antigen init ~/.antigenrc > /dev/null 2>&1
  antigen cache-gen
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
