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
