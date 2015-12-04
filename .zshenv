export PATH=/usr/local/sbin:$PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# RVM
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Travis
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# Maven
export M2_HOME=/usr/local/Cellar/maven/3.3.9/libexec

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Octopress
alias rake="noglob rake"
