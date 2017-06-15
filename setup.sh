#!/bin/sh

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
git config --global alias.hist 'log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'
git config --global core.excludesfile ~/.gitignore_global
git config --global help.autocorrect 5

echo bin setup
if [ ! -d "$HOME/bin/" ]; then
	mkdir "$HOME/bin"
fi

echo git setup
if [ ! -d "$HOME/.gitignore_global" ]; then
	touch "$HOME/.gitignore_global"
	cat ./.dotfiles/gitignore_global >> "$HOME/.gitignore_global"
fi

if [ ! -d "/usr/local/git/contrib/completion/" ]; then
	brew install git bash-completion
fi

echo First Time Setup
read -p "Run first time setup? " -n 1 -r
echo .   
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo Running first time setup
if [ ! -d "$HOME/.bash_profile" ]; then
	touch "$HOME/.bash_profile"
	cat ./.dotfiles/bash_profile >> "$HOME/.bash_profile"
fi




