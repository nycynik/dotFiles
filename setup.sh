#!/bin/bash

# global functions
if [[ -f functions ]]; then
    # shellcheck source=functions
    source functions
else
    echo "⛔ Could not find functions. Exiting..."
    exit 1
fi

function showScreen() {
  clear
  draw_title "Welcome to your new home setup!"
}

# global variables
original_dir=$(pwd)
zshrc="${HOME}/.zshrc"
bashprofile="${HOME}/.bash_profile"
marker="# DOTFILES - DO NOT REMOVE THIS LINE"
username=""
email=""
if command_exists git; then
    username=$(git config --global user.name)
    email=$(git config --global user.email)
fi
post_install_tasks="${HOME}/.dotfiles/logs/post_install_tasks_$(date +%Y%m%d).log"
brew_log="${HOME}/.dotfiles/logs/brew_log_$(date +%Y%m%d).log"

export post_install_tasks
export brew_log

## ---------------------------
## Main script
## ---------------------------

# verify we are int he right directory
if [[ "${original_dir}" != "${HOME}" ]] ; then
    echo "NOTE: script is not running from your home dir. (HOME set to $HOME)"
    if [ ! -L ~/.dotfiles ]; then
        read -p "Create symlink from home to ${PWD} [Y/n]? " -n 1 -r
        if [[ "$REPLY" =~ ^[yY]$ ]] ; then
            ln -s "${PWD}" ~/.dotfiles
        else
            echo "⛔ Could not run from another directory without a symlink to this one. Exiting..."
            exit 120
        fi
    fi
fi

# Let's get some fun color and stuff!
if [[ -f ./scripts/prettyfmt.sh ]]; then
    clear
    source ./scripts/prettyfmt.sh
else
    echo "⛔ Could not find ~/scripts/prettyfmt.sh. Exiting..."
    exit 1
fi

# OS Selection
showScreen

# Guess OS
detected_os=""
if [ "$(uname)" == "Darwin" ]; then
    detected_os="OSX"
elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    detected_os="WSL"
elif [ "$(uname -s)" == "Linux" ]; then
    detected_os="Ubuntu"
fi

# Prompt user for confirmation
colorful_echo "\n${WHITE}🔮 Your OS might be: ${GREEN}$detected_os\n"
if [[ "$detected_os" == "WSL" ]] ; then
    colorful_echo "1) ${YELLOW}WSL ${BLUE}(Default)"
else
    colorful_echo "1) ${GREEN}WSL"
fi
if [[ "$detected_os" == "Ubuntu" ]] ; then
    colorful_echo "2) ${YELLOW}Ubuntu ${BLUE}(Default)"
else
    colorful_echo "2) ${GREEN}Ubuntu"
fi
if [[ "$detected_os" == "OSX" ]] ; then
    colorful_echo "3) ${YELLOW}OSX ${BLUE}(Default)"
else
    colorful_echo "3) ${GREEN}OSX"
fi
colorful_echo "4) ${GREEN}Exit\n"

# Get user choice
read -rp "Which OS [1-4, or enter for $detected_os]: " choice

selected_os=""
# If the user presses Enter without entering anything, the choice variable will be empty
if [[ -z "$choice" ]]; then
    echo "Proceeding with the default detected OS: $detected_os"
    selected_os=$detected_os
elif [[ "$choice" =~ ^[1-3]$ ]]; then
    echo "You chose option $choice"
    selected_os=$(case $choice in
        1) echo "WSL";;
        2) echo "Ubuntu";;
        3) echo "OSX";;
    esac)
elif [[ "$choice" == "4" ]]; then
    echo "${YELLOW}Exiting without making any changes. Have a nice day!"
    exit 0
else
    echo "⛔ ${RED}Invalid choice.${YELLOW} Exiting..."
    exit 1
fi

# Gather Info
showScreen

colorful_echo "${YELLOW}Let's set up your name for github and other services.\n"

read -rp "$(echo -e "${BLUE}"Full Name "${GREEN}"["${YELLOW}""$username""${GREEN}"]"${WHITE}":"${GREEN}")" USERNAME
USERNAME="${USERNAME:-$username}"  # Use $username as default if USERNAME is empty

read -rp "$(echo -e "${BLUE}" "   Email" "${GREEN}"["${YELLOW}""$email""${GREEN}"]"${WHITE}":"${GREEN}")" USEREMAIL
USEREMAIL="${USEREMAIL:-$email}"

# Confirm
showScreen

colorful_echo "\n🖥️ ${BLUE}OS Selected${WHITE}: ${GREEN}$selected_os"
colorful_echo "📬   ${BLUE}User Info${WHITE}: ${GREEN}${USERNAME} <${USEREMAIL}>"
colorful_echo "🏠 ${BLUE}Home Folder${WHITE}: ${GREEN}${HOME}"
[[ ! -d "$HOME/.oh-my-zsh" ]] && colorful_echo "📜 ${BLUE}       P10k${WHITE}: ${GREEN}Will be installed"
command_exists "brew" || colorful_echo "🍺 ${BLUE}Homebrew${WHITE}: ${YELLOW}Not Installed"
command_exists "git" || colorful_echo "🐙 ${BLUE}       Git${WHITE}: ${YELLOW}Not Installed"

echo -en "\n👋 ${WHITE}Are you ready to run first time setup? ${GREEN}[y/N]"
read -n 1 -r response

if [[ $response =~ ^[Yy]$ ]]
then
    colorful_echo "\n\n${BLUE}Great${WHITE}! ${GREEN}Let's begin the setup process${WHITE}.\n"
else
    colorful_echo "\n\n${YELLOW}Setup cancelled${WHITE}. \n${BLUE}You can run this script again when you're ready${WHITE}."
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# sudo -v

# Setup
draw_a_line "LINE"
draw_sub_title "Setting up your environment"
draw_a_line "LINE"

# if the directory ${HOME}/.dotfiles does not exist, make it
if [[ ! -d "${HOME}/.dotfiles" ]] ; then
	mkdir "${HOME}/.dotfiles"
    colorful_echo " • ${BLUE}Created dotfiles folder${WHITE}."
fi

# Create the logs directory if it doesn't exist
if [[ ! -d "${HOME}/.dotfiles/logs" ]] ; then
    mkdir "${HOME}/.dotfiles/logs"
    colorful_echo " • ${BLUE}Created logs folder${WHITE}."
fi

# Create the post install tasks file if it doesn't exist
if [[ -f "${post_install_tasks}" ]] ; then
	mv "${post_install_tasks}" "${post_install_tasks}.$(date +%Y%m%d)"
fi
touch "${post_install_tasks}"

# if the brew_log.log file exists in the .dotfiles dir, back it up by renaming it
# with todays date.
if [[ -f "${brew_log}" ]] ; then
	mv "${brew_log}" "${HOME}/.dotfiles/logs/brew_log.bak.$(date +%Y%m%d)"
    colorful_echo " • ${BLUE}Backed up previous brew log${WHITE}."
fi
touch "${brew_log}"

if [[ ! -d "$HOME/bin/" ]]; then
	mkdir "$HOME/bin"
    colorful_echo "   • ${BLUE}Created bin folder${WHITE}.\n"
fi
cp -Rf ./scripts/* "$HOME/bin/"

if [[ ! -f "${zshrc}" ]] ; then
    colorful_echo "   • ${BLUE}Created ${GREEN}${zshrc}${WHITE}."
	cp ./.zshrc "${HOME}/.zshrc"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    colorful_echo "   • ${BLUE}Installing oh-my-zsh${WHITE}."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -f "$HOME/.p10k.zsh" ]]; then
    colorful_echo "   • ${BLUE}Installing powerlevel10k${WHITE}."
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
	pk10k configure
fi

if ! grep -q "$marker" "$zshrc"; then
    {
        echo -e "\n$marker"
        echo 'if [[ -f ~/.dotfiles/aliases ]]; then source ~/.dotfiles/aliases; fi'
        echo 'if [[ -f ~/.dotfiles/functions ]]; then source ~/.dotfiles/functions; fi'
     } >> "$zshrc"
    colorful_echo "   • ${BLUE}Added config to ${GREEN}~/.zshrc${WHITE}."
fi

if [[ ! -f "${bashprofile}" ]] ; then
    colorful_echo "   • ${BLUE}Created ${GREEN}${bashprofile}${WHITE}."
	cp ./.zshrc "${HOME}/.zshrc"
fi

if ! grep -q "$marker" "$bashprofile"; then
    {
        echo -e "\n$marker"
        echo 'if [[ -f ~/.dotfiles/aliases ]]; then source ~/.dotfiles/aliases; fi'
        echo 'if [[ -f ~/.dotfiles/functions ]]; then source ~/.dotfiles/functions; fi'
    } >> "$bashprofile"
    colorful_echo "   • ${BLUE}Added config to ${GREEN}${bashprofile}${WHITE}."
fi

# Setup Homebrew
draw_a_line "LINE"
draw_sub_title "Setting up Homebrew"
draw_a_line "LINE"

if ! command_exists brew; then
    # Install Homebrew
    colorful_echo "   • ${BLUE}Installing Homebrew${WHITE}."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	output="$(brew doctor)"

	if [[ $output == *"Your system is ready to brew."* ]]; then
		colorful_echo "   - ${BLUE}Homebrew is healthy."
	else
		colorful_echo "   - ${RED}Error! {$BLUE}Issues detected with Homebrew${WHITE}: {$BLUE}check ~/.dotfiles/brew_diagnostics.log${WHITE}."
		echo "$output" > "${HOME}/.dotfiles/brew_diagnostics.log"
	fi
fi
brew update && brew upgrade -q
{
    echo "## Homebrew Setup" >> "$post_install_tasks"
    echo "You should review the brew isntallation logs at $brew_log."
    echo "You may need to open a new terminal for settings to take effect."
 } >> "$post_install_tasks"

# Git
echo "## Git Setup" >> "$post_install_tasks"
if ! command_exists git; then
    # Install Git
    colorful_echo "   • ${BLUE}Installing Git${WHITE}."
    brew install git
fi
if [[ ! -d "$HOME/.gitconfig" ]]; then
	cp ./.gitconfig "$HOME/.gitconfig"
fi

if [[ ! -d "$HOME/.gitignore_global" ]]; then
	touch "$HOME/.gitignore_global"
	cat ./gitignore_global >> "$HOME/.gitignore_global"
fi

if [[ ! -d "$HOME/.git-hooks" ]]; then
    mkdir "$HOME/.git-hooks"
    cp ./pre-commit "$HOME/.git-hooks/pre-commit"
    chmod +x "$HOME/.git-hooks/pre-commit"
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
# shellcheck disable=SC2016
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%C(auto)%d$Creset [%an]" --graph --date=short'

git config --global core.excludesfile ~/.gitignore_global
git config --global init.defaultBranch main
git config --global core.hooksPath ~/.git-hooks
git config --global help.autocorrect 5
git config --global init.defaultBranch main
git config --global user.name "$USERNAME"
git config --global user.email "$USEREMAIL"

echo "Add your SSH keys for git and update the ~/.ssh/config" >> "$post_install_tasks"

# -----------------------------------------
# Dev tools
draw_a_line "LINE"
draw_sub_title "Setting up Dev Tools"
draw_a_line "LINE"

# if tee is not isntalled, isntall it with brew.
if ! command_exists tee; then
	brew install tee
    colorful_echo "   • ${BLUE}Installed ${GREEN}tee${WHITE}."
fi
# dev tools
command_exists watchman || brew install watchman 2>&1 | tee -a "${brew_log}"
command_exists http || brew install httpie 2>&1 | tee -a "${brew_log}"
command_exists tree || brew install tree 2>&1 | tee -a "${brew_log}"
command_exists jq || brew install jq 2>&1 | tee -a "${brew_log}"
command_exists eza || brew install eza 2>&1 | tee -a "${brew_log}"

# JavaScript
draw_a_line "LINE"
draw_sub_title "Setting up JavaScript"
draw_a_line "LINE"

command_exists node || brew install node 2>&1 | tee -a "${brew_log}"
if ! command_exists nvm; then

	mkdir -p ~/.nvm
	brew install nvm 2>&1 | tee -a "${brew_log}"

   	cat <<EOT >> "${HOME}/.zshrc"
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
EOT
	nvm install --lts
fi
command_exists pnpm || brew install pnpm 2>&1 | tee -a "${brew_log}"

# Java
draw_a_line "LINE"
draw_sub_title "Setting up Java"
draw_a_line "LINE"

echo "## Java Setup" >> "$post_install_tasks"
command_exists mvn || brew install maven 2>&1 | tee -a "${brew_log}"
command_exists gradle || brew install gradle 2>&1 | tee -a "${brew_log}"
{
    echo "Add your maven settings.xml file to ~/.m2/settings.xml"
    echo "Add your gradle settings to ~/.gradle/gradle.properties"
    echo "Verify the JAVA_HOME is set correctly to JAVA_HOME=$JAVA_HOME"
} >> "$post_install_tasks"
if ! command_exists jenv ; then
    brew install jenv 2>&1 | tee -a "${brew_log}"
    # shellcheck disable=SC2016
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bash_profile
    # shellcheck disable=SC2016
    echo 'eval "$(jenv init -)"' >> ~/.bash_profile
    # shellcheck disable=SC2016
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    # shellcheck disable=SC2016
    echo 'eval "$(jenv init -)"' >> ~/.zshrc
    echo "If you need additional java installations do so and use jenv add." >> "$post_install_tasks"
fi
echo "Check Java version to make sure it's up to date. Javac version is $(javac --version)." >> "$post_install_tasks"

# Python
draw_a_line "LINE"
draw_sub_title "Setting up Python"
draw_a_line "LINE"
command_exists uv || brew install uv 2>&1 | tee -a "${brew_log}"

if [[ ! -d "{HOME}/.venv" ]]; then
    mkdir "{HOME}/.venv"
    uv python install 3.12
    uv venv "${HOME}/.venv/dev"
    # shellcheck source=/dev/null
    source "${HOME}/.venv/dev/bin/activate"
    command_exists pre-commit || uv  install pre-commit
fi
if ! command_exists pipx; then
    brew install pipx 2>&1 | tee -a "${brew_log}"
    pipx ensurepath
fi

# PHP
command_exists php || brew install php 2>&1 | tee -a "${brew_log}"
command_exists composer || brew install composer 2>&1 | tee -a "${brew_log}"

# SSH Config
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh${WHITE}."
fi
if [[ ! -f "$HOME/.ssh/config" ]]; then
    touch "$HOME/.ssh/config"
    {
        printf "# SSH CONFIG\n\n# Include ~/.ssh/localservers/n"
        printf "Host github.com\n  ForwardX11 no"
        printf "\nHost *\n  ForwardAgent yes\n  ForwardX11 yes\n  VisualHostKey yes"
    } >> "${HOME}/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/config${WHITE}."
fi

# Run the corresponding script
case $selected_os in
    "WSL")
        bash "$original_dir"/setupscripts/wsl-setup.sh
        ;;
    "Ubuntu")
        bash "$original_dir"/setupscripts/linux-setup.sh
        ;;
    "OSX")
        bash "$original_dir"/setupscripts/mac-setup.sh
        ;;
esac

# Post machine specific stuff
draw_a_line "LINE"
draw_sub_title "Post OS Install setup"
draw_a_line "LINE"

# Dart & Flutter
flutter doctor
echo "## Dart and Flutter Setup" >> "$post_install_tasks"
if ! command_exists fvm; then
    colorful_echo "Installing FVM..."
    sh -c "$(curl -fsSL https://fvm.app/install.sh)"

    brew tap leoafarias/fvm
    brew install fvm 2>&1 | tee -a "${brew_log}"
    echo "Run fvm flutter doctor to ensure flutter is working" >> "$post_install_tasks"
    echo "Verify the simulator works via 'open -a Simulator' for mac or Android Studio for Android" >> "$post_install_tasks"
    mkdir -p ~/.fvm
    fvm install stable
    fvm global stable
    echo "export PATH='$HOME/.fvm/bin:$PATH'" >> ~/.bash_profile
    echo "export PATH='$HOME/.fvm/bin:$PATH'" >> ~/.zshrc
    echo "You may want to install more versions of the Dart/Flutter SDK, via fvm install <version>" >> "$post_install_tasks"
    fvm use stable
    fvm flutter doctor --android-licenses
fi
#command_exists flutter || brew install flutter 2>&1 | tee -a "${brew_log}"

draw_a_line "LINE"
draw_sub_title "🎉 Setup complete! Have a great day! 🎉"
draw_a_line "LINE"

colorful_echo "\n${YELLOW}Post-Installation Tasks${WHITE}:"
while IFS= read -r line; do
    if [[ $line == \#\#* ]]; then
        # It's a section header
        echo -e "\n${BLUE}${line#\#\# }:${WHITE}"
    else
        # It's a regular item
        echo -e "${YELLOW}  • ${WHITE}$line"
    fi
done < "$post_install_tasks"

cd "${original_dir}" || exit 1
exit 0
