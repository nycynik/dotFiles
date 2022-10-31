#!/bin/sh

if [[ ! -d "${PWD}/.dotfiles" ]] ; then
	echo "ABORTING: No .dotfiles found in current directory."
	echo "          Script must be run from root of dotfiles repo."
    	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don'$
fi

if [[ "${PWD}" != "${HOME}" ]] ; then
        echo "NOTE: script is not running from your home dir" 
        read -p "Create symlink in ${PWD} [Y/n]? " -n 1 -r
        if [[ "$REPLY" =~ ^[yY]$ ]] ; then
                ln -s ./dotfiles ${PWD}/.dotfiles
        fi
fi

echo bin setup
if [[ ! -d "$HOME/bin/" ]]; then
	mkdir "$HOME/bin"
fi

echo git setup
if [[ ! -d "$HOME/.gitignore_global" ]]; then
	touch "$HOME/.gitignore_global"
	cat ./.dotfiles/gitignore_global >> "$HOME/.gitignore_global"
fi

if [[ ! -d "/usr/local/git/contrib/completion/" ]]; then
	brew install git bash-completion
fi

echo First Time Setup
read -p "Run first time setup? " -n 1 -r
echo .   
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo ==========================================================
echo Running first time setup
echo ==========================================================

if [[ ! -d "$HOME/.bash_profile" ]]; then
	touch "$HOME/.bash_profile"
	cat ./.dotfiles/bash_profile >> "$HOME/.bash_profile"
fi

echo "bash setup"
echo git config
git config --global core.editor nano
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.ss 'status -s'
git config --global alias.last 'log -1 HEAD'
git config --global alias.p 'pull --rebase'
git config --global alias.type 'cat-file -t'
git config --global alias.dump 'cat-file -p'
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%C(auto)%d$Creset [%an]" --graph --date=short'
git config --global core.excludesfile ~/.gitignore_global
git config --global help.autocorrect 5

# setup quicklook
brew update
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv qlimagesize webpquicklook suspicious-package
brew install betterzip
brew install jq bash

# dev tools
brew install watchman
brew install httpie

# window tools
brew install rectangle

# zsh
brew install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Finished Setup"
echo .
echo "You may want to remove the lic and ReadMe files from your home directory now."

read -p "Delete LICENSE and README.md now? " -n 1 -r
echo .
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rm LICENSE
	rm README.md
fi




