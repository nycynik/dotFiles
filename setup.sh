#!/bin/bash

if [[ "${PWD}" != "${HOME}" ]] ; then
        echo "NOTE: script is not running from your home dir. (HOME set to $HOME)" 
        read -p "Create symlink in ${PWD} [Y/n]? " -n 1 -r
        if [[ "$REPLY" =~ ^[yY]$ ]] ; then
                ln -s ./dotfiles ${PWD}
        fi
fi

echo ==========================================================
echo Global Set up
echo ==========================================================

echo Hi! 🎉
echo what is your name?
read USERNAME

echo what is your email?
read USEREMAIL

echo ----------------------------------------------------------
echo First Time Setup
echo ----------------------------------------------------------
read -p "Hey $username, 📛\nAre you ready to run first time setup? " -n 1 -r
echo .   
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo ==========================================================
echo Running first time setup  🚀🚀🚀
echo ==========================================================

echo bin setup
echo ----------------------------------------------------------
if [[ ! -d "$HOME/bin/" ]]; then
	mkdir "$HOME/bin"
fi

echo Homebrew setup 
echo ----------------------------------------------------------
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo Run brew doctor when finished.
fi
brew update
brew upgrade

echo  Setting up zsh
echo ----------------------------------------------------------
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [[ ! -d "$HOME/.p10k.zsh" ]]; then
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	pk10k configure
fi

if [[ ! -d "${HOME}/.zshrc" ]] ; then
	cp ./.zshrc "${HOME}/.zshrc"
else
cat <<EOT >> "${HOME}/.zshrc"
if [[ -f ~/.dotfiles/aliases ]]; then
    source ~/.dotfiles/aliases
fi

# personal functions
if [[ -f ~/.dotfiles/functions ]]; then
    source ~/.dotfiles/functions
fi
EOT
fi

echo git setup
echo ----------------------------------------------------------
echo NOTE: add your ssh keys
if [ -x "$(command -v git)" ]; then
	brew install git
fi

if [[ ! -d "$HOME/.gitconfig" ]]; then
	cp ./.gitconfig "$HOME/.gitconfig"
fi

if [[ ! -d "$HOME/.gitignore_global" ]]; then
	touch "$HOME/.gitignore_global"
	cat ./gitignore_global >> "$HOME/.gitignore_global"
fi
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

echo Dev tools and CLI tools
echo ----------------------------------------------------------

brew install betterzip

# dev tools
brew install watchman
brew install httpie
brew install tree jq

if [[ ! -d "$HOME/.nvm" ]]; then
	mkdir ~/.nvm
	brew install nvm
	cat <<EOT >> "${HOME}/.zshrc"
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
EOT
	nvm install --lts
	npm install --global yarn
fi

# java
brew install maven

#python
mkdir "$HOME/.venv"
python -m venv "$HOME/.venv/dev"
source "$HOME/.venv/dev/bin/activate"
python -m pip install --upgrade pip
brew install pipx
pipx ensurepath
pip install pre-commit


# window tools
brew install rectangle

brew install eza
alias ll='eza --icons --hyperlink -la'

# xcode
if [ -x "$(command -v xcode-select)" ]; then
	xcode-select --install
fi

echo "Finished Setup"

read -p "Clean up? " -n 1 -r
echo .
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rm LICENSE
	rm README.md
fi




