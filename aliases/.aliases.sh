# Git
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

gdiff() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview $preview
}

# Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

# Maven
alias mver="mvn versions:display-dependency-updates versions:display-plugin-updates | grep 'INFO' | grep '>' | sort | uniq"

# Add confirmation when removing files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

jwtd() {
  h=`jq -R 'split(".") | .[0] | @base64d | fromjson' <<< "$1"` > /dev/null
  p=`jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"` > /dev/null
  echo "Header:\n"
  echo $h | jq
  echo "\nPayload:\n"
  echo $p | jq
}

alias vim=nvim
