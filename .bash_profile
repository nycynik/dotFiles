# include .bashrc and profile
[[ -s "$HOME/.profile" ]] && source ~/.profile
[[ -s "$HOME/.bashrc" ]] && source ~/.bashrc

# include my dotfiles.
source ~/.dotfiles/aliases
source ~/.dotfiles/prompt
source ~/.dotfiles/development

# include my personal bin folder in the Path
export PATH=$PATH:~/bin

# bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi