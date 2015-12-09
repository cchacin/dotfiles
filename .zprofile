# Docker
if which docker-machine > /dev/null; then
  if [[ $(docker-machine status default) == 0 ]]; then
    docker-machine env default > /dev/null
    eval "$(docker-machine env default)" > /dev/null
    docker-machine start default > /dev/null
  else
    echo "Docker already running..."
  fi
fi

# RVM
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Travis
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Octopress
alias rake="noglob rake"
