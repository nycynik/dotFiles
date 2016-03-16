
source ~/bin/mvn.sh

source ~/.dotfiles/aliases

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source ~/.profile

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/mlynch/.gvm/bin/gvm-init.sh" ]] && source "/Users/mlynch/.gvm/bin/gvm-init.sh"
