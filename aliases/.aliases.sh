# Git
alias gitlog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Finder
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app"

# Maven
mver() {
  mvn versions:display-dependency-updates \
      versions:display-plugin-updates \
      versions:display-property-updates \
      -Dmaven.version.ignore="(?i).*(alpha|beta|rc|cr|m[0-9]|preview|snapshot).*" \
      "$@" | awk '
    /^\[INFO\] The following (dependencies in .* have newer versions|plugin updates are available|version property updates are available|parent update)/ {
      in_updates = 1
      section = $0
      sub(/^\[INFO\] /, "", section)
      next
    }
    /^\[INFO\] *$/ || /^\[INFO\] [^ ]/ {
      in_updates = 0
    }
    in_updates && / -> / {
      line = $0
      sub(/^\[INFO\] +/, "  ", line)
      if (section != "") {
        print "\n" section
        section = ""
      }
      print line
      count++
    }
    END {
      if (count == 0) {
        print "All dependencies, plugins, and properties are up to date."
      }
    }
  '
}

# Add confirmation when removing files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vim=nvim
alias vi=nvim

zstyle ':omz:plugins:eza' 'git-status' yes
