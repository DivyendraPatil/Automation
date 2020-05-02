#!/usr/bin/env zsh

set -e

# Change default shell to zsh
chsh -s /bin/zsh

echo -e "Installing brew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo -e "Install iterm2"
echo -e "Install docker"
sleep 10

# Checking python and installing pip
python3 --version
python3 get-pip.py

pip3 install requests
brew install awscli
brew install nmap
brew install wget

echo -e "Installing oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo -e "Installed oh my zsh"

echo -e "Writing path to .zshrc"
echo "export PATH=/usr/local/bin:\$PATH" >> ~/.zshrc
echo -e "Wrote path to .zshrc"

echo -e "Writing theme settings"
cat > /Users/$USER/.oh-my-zsh/themes/robbyrussell.zsh-theme <<- EOM
local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
NEWLINE=$'\n'
PROMPT='%n@%m ${NEWLINE} ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
EOM
echo -e "Wrote theme settings"

echo -e "Setting mac settings"
sudo systemsetup -setrestartfreeze on
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName


alias "updatedocker=docker images |grep -v REPOSITORY|awk '{print $1}'|xargs -L1 docker pull"
alias "gs=git status"
alias "..=cd .."
alias "clearpath=PATH=$(echo $PATH | awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')"
alias "c=clear"
alias "updatedocker=docker images | grep -v REPOSITORY | awk '{print \$1}' | xargs -L1 docker pull"
alias "lip=ifconfig | grep 'inet ' | cut -d ' ' -f2 "
alias "eip=curl icanhazip.com"
alias "resetdnscache=sudo killall -HUP mDNSResponder; sleep 2; echo macOS DNS Cache Reset"


# Installing xcode
xcode-select -p
xcode-select --install


# Go Development
export GOPATH="${HOME}/.go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
test -d "${GOPATH}" || mkdir "${GOPATH}"
test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"

brew install go
go get golang.org/x/tools/cmd/godoc
go get github.com/golang/lint/golint

