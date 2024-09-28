# include .bashrc and profile
[[ -s "$HOME/.profile" ]] && source ~/.profile
[[ -s "$HOME/.bashrc" ]] && source ~/.bashrc

# include my dotfiles.
source ~/.dotfiles/functions
source ~/.dotfiles/aliases
source ~/.dotfiles/env
source ~/.dotfiles/development
source ~/.dotfiles/dev_prompt

# include my personal bin folder in the Path
if [ -d "$HOME/bin/" ]; then
	export PATH=$PATH:~/bin
fi

# bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi



