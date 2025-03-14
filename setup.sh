#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/addfunctions.sh ]] && source ./setupscripts/addfunctions.sh || {
    echo "setup-helpers.sh not found"
    exit 199
}

showScreen() {
  clear
  draw_title "Welcome to your new home setup!"
}

# global variables
original_dir=$(pwd)
username=""
email=""

# if git exists, we can load the username and email from there.
if command_exists git; then
    username=$(git config --global user.name)
    email=$(git config --global user.email)
fi

## ---------------------------
## Main script
## ---------------------------

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# User input / setup section
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------

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

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
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
    colorful_echo "You chose option ${BLUE}${choice}"
    declare -A os_types=(
        [1]="WSL"
        [2]="Ubuntu"
        [3]="OSX"
    )
    selected_os=${os_types[$choice]}
elif [[ "$choice" == "4" ]]; then
    echo "${YELLOW}Exiting without making any changes. Have a nice day!"
    exit 0
else
    echo "⛔ ${RED}Invalid choice.${YELLOW} Exiting..."
    exit 1
fi

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Gather Info
showScreen

colorful_echo "${WHITE}Let's set up your name for github and other services.\n"

read -rp "$(echo -e "${BLUE}"Full Name "${GREEN}"["${YELLOW}""$username""${GREEN}"]"${WHITE}":"${GREEN}")" USERNAME
USERNAME="${USERNAME:-$username}"  # Use $username as default if USERNAME is empty

read -rp "$(echo -e "${BLUE}" "   Email" "${GREEN}"["${YELLOW}""$email""${GREEN}"]"${WHITE}":"${GREEN}")" USEREMAIL
USEREMAIL="${USEREMAIL:-$email}"

# generate a random passphrase
PASSPHRASE=$(openssl rand -base64 32)
read -rp "$(echo -e "${BLUE}" "   Passphrase" "${GREEN}"["${YELLOW}${PASSPHRASE}${GREEN}"]"${WHITE}":"${GREEN}")" PASSPHRASE
PASSPHRASE="${PASSPHRASE:-supersecurepassphrase}"
PASSPHRASE=$(echo "$PASSPHRASE" | tr -d '\n')  # Remove newlines from the passphrase

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Confirm Info
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

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Installation Section
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Setup Shell
draw_a_line "LINE"
draw_sub_title "Setting up your shell and environment"
draw_a_line "LINE"

# if the directory ${HOME}/.dotfiles does not exist, make it
if [[ ! -d "${HOME}/.dotfiles" ]] ; then
	mkdir "${HOME}/.dotfiles"
    colorful_echo " • ${BLUE}Created dotfiles folder${WHITE}."
fi

# Create the logs directory if it doesn't exist
if [[ ! -d "${HOME}/.dotfiles/logs" ]] ; then
    mkdir -p "${HOME}/.dotfiles/logs"
    colorful_echo " • ${BLUE}Created logs folder${WHITE}."
fi

if [[ ! -d "$HOME/bin/" ]]; then
	mkdir "$HOME/bin"
    add_config_to_shells "PERSONAL-BIN" <<'EOF'
# include my personal bin folder in the Path
if [ -d "$HOME/bin/" ]; then
	export PATH=$PATH:~/bin
fi
EOF
    colorful_echo "   • ${BLUE}Created bin folder${WHITE}.\n"
fi

if [[ ! -d "${HOME}/scripts/" ]]; then
    mkdir "${HOME}/scripts"
    cp -Rf ./scripts/* "$HOME/scripts/"
    colorful_echo "   • ${BLUE}Created scripts folder${WHITE}."
fi

# ensure bash profile and zshrc exist, they should
if [[ ! -f "${HOME}/.bash_profile" ]] ; then
    colorful_echo "   • ${BLUE}Created ${GREEN}${HOME}/.bash_profile${WHITE}."
	cp ./bash_profile ~/.bash_profile
fi
if [[ ! -f "${HOME}/.zshrc" ]] ; then
    colorful_echo "   • ${BLUE}Created ${GREEN}${HOME}/.zshrc${WHITE}."
	cp ./.zshrc "${HOME}/.zshrc"
fi

# Install Oh My Zsh if not installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    colorful_echo "   • ${BLUE}Installing Oh My Zsh${WHITE}."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || exit 1
fi

# Install Powerlevel10k theme if not installed
P10K_CONFIG_SOURCE=".p10k.zsh" # Path to Powerlevel10k config in this repo
P10K_CONFIG_DEST="$HOME/.p10k.zsh"
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    colorful_echo "   • ${BLUE}Installing Powerlevel10k${WHITE}."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    # Ensure Powerlevel10k is set as the theme in .zshrc
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

    # Copy existing Powerlevel10k config
    if [[ -f "$P10K_CONFIG_SOURCE" ]]; then
        cp "$P10K_CONFIG_SOURCE" "$P10K_CONFIG_DEST"
    fi
fi

install_zsh_plugin "https://github.com/marlonrichert/zsh-autocomplete.git"
install_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions.git"
install_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git"


# add functions and aliases to shell
add_config_to_shells "dotFiles" <<'EOF'
    if [[ -f ~/.dotfiles/aliases ]]; then source ~/.dotfiles/aliases; fi'
    if [[ -f ~/.dotfiles/functions ]]; then source ~/.dotfiles/functions; fi'
EOF

# bash completion
install_brew_package "bash-completion"
if [[ ! -d "$HOME/.bash_completion.d" ]]; then
    mkdir "$HOME/.bash_completion.d"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.bash_completion.d${WHITE}."
fi
# add only to .bash_profile, so we dont' use add_config_to_shells
if ! grep -q "bash_completion.d" ~/.bash_profile; then
    {
        echo "# Added by Dotfiles - DO NOT REMOVE THIS LINE - BASH-COMPLETION"
        echo "if [ -d ~/.bash_completion.d ]; then"
        echo "    for file in ~/.bash_completion.d/*; do"
        echo "        [ -r \"\$file\" ] && [ -f \"\$file\" ] && source \"\$file\";"
        echo "    done"
        echo "fi"
        echo "# Added by Dotfiles - DO NOT REMOVE THIS LINE - BASH-COMPLETION-END"
    }  >> ~/.bash_profile
fi

# SSH Config
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh${WHITE}."
fi
if [[ ! -f "$HOME/.ssh/config" ]]; then
    touch "$HOME/.ssh/config"
    printf "# SSH CONFIG\n\n# Include ~/.ssh/localservers/n" >> "${HOME}/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/config${WHITE}."
fi

# create keys if they don't exist
eval "$(ssh-agent -s)"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -C "$USEREMAIL" -f "$HOME/.ssh/id_ed25519"
    ssh-add ~/.ssh/id_ed25519
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/id_rsa${WHITE}."
fi

if [[ ! -f "$HOME/.ssh/github_key" ]]; then
    ssh-keygen -t ed25519 -C "$USEREMAIL" -f "$HOME/.ssh/github_key"
    ssh-add ~/.ssh/github_key
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/github_key${WHITE}."
    add_post_install_instructions "SSH" "Add your SSH keys for git to github.com (pbcopy < ~/.ssh/github_key on mac) https://github.com/settings/keys "
    printf "\nHost github.com\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/github_key\n  IdentitiesOnly yes\n  ForwardX11 no\n" >> "${HOME}/.ssh/config"
fi


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Setup Homebrew
draw_a_line "LINE"
draw_sub_title "Setting up Homebrew"
draw_a_line "LINE"

if ! command_exists brew; then
    # Install Homebrew
    colorful_echo "   • ${BLUE}Installing Homebrew${WHITE}."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # activate brew
    command -v brew || export PATH="/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin"
    command -v brew && eval "$(brew shellenv)"

    output="$(brew doctor)"

	if [[ $output == *"Your system is ready to brew."* ]]; then
		colorful_echo "   - ${BLUE}Homebrew is healthy."
	else
		colorful_echo "   - ${RED}Error! {$BLUE}Issues detected with Homebrew${WHITE}: {$BLUE}check ~/.dotfiles/brew_diagnostics.log${WHITE}."
		echo "$output" > "${HOME}/.dotfiles/brew_diagnostics.log"
        exit 3
	fi
else
    colorful_echo "   • ${YELLOW}Homebrew already installed, updating${WHITE}."
fi
brew update && brew upgrade
post_install_instructions "Homebrew" "You may need to open a new terminal for some settings to take effect."
post_install_instructions "Homebrew" "You should review the brew installation logs at $(brew_get_brew_log_path)"
post_install_instructions "Homebrew" "brew doctor was run, and you are ready to brew, but you may want to run it again and see if there were any warnings or to-dos."
# if tee is not isntalled, isntall it with brew.
if ! command_exists tee; then
	brew install tee # can't use function for this one, because function requres tee.
    colorful_echo "   • ${BLUE}Installed ${GREEN}tee${WHITE}."
fi

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Setup Identity
draw_a_line "LINE"
draw_sub_title "Identity"
draw_a_line "LINE"

install_brew_package "gpg"
if ! command -v gpg >/dev/null 2>&1; then
    colorful_echo "   • ${RED}GPG failed to install${WHITE}."
    exit 112
fi

if [[ ! -d "$HOME/.gnupg" ]]; then
    mkdir "$HOME/.gnupg"
    colorful_echo "   • ${BLUE}Created ${GREEN}~/.gnupg${WHITE}."
fi
# generate keys
GPG_BATCH_CONTENT="$(cat <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 4096
    Name-Real: $USERNAME
    Name-Email: $USEREMAIL
    Expire-Date: 1y
    Passphrase: $PASSPHRASE
    %commit
    %echo done
EOF
)"
# Create temporary batch file
BATCH_FILE=$(mktemp)
echo "$GPG_BATCH_CONTENT" > "$BATCH_FILE"

# Generate the key
gpg --batch --generate-key "$BATCH_FILE"

# Clean up the batch file
rm "$BATCH_FILE"

colorful_echo "   • ${BLUE}Created GPG key${WHITE}."
# storing this for git setup later
gpgkey=$(gpg --list-secret-keys --keyid-format LONG)


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Setup Git
draw_a_line "LINE"
draw_sub_title "Setting up Git"
draw_a_line "LINE"

install_brew_package "git"
if [[ ! -f "$HOME/.gitconfig" ]]; then
	cp ./.gitconfig "$HOME/.gitconfig"
fi
if [[ ! -f "$HOME/.gitignore_global" ]]; then
	touch "$HOME/.gitignore_global"
	cat ./gitignore_global >> "$HOME/.gitignore_global"
fi

if [[ ! -d "$HOME/.git-hooks" ]]; then
    mkdir -p "$HOME/.git-hooks"
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
git config --global user.signingkey "$gpgkey"
git config --global commit.gpgsign true
git config --global gpg.program gpg

git config --global user.name "$USERNAME"
git config --global user.email "$USEREMAIL"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Dev tools
draw_a_line "LINE"
draw_sub_title "Setting up Dev Tools"
draw_a_line "LINE"

# dev tools
install_brew_package "watchman"
install_brew_package "httpie"
install_brew_package "tree"
install_brew_package "jq"
install_brew_package "eza"
install_brew_package "shellcheck"

add_post_install_instructions "Dev Tools Setup" "Add vscode to the command line. Launch vscode, c-a-P 'term' and then click add it. If there are any issues, you may need to remove /usr/bin/local/code first."

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Flutter
draw_a_line "LINE"
draw_sub_title "Flutter, Dart, FVM"
draw_a_line "LINE"

# Dart & Flutter
if ! command_exists fvm; then
    colorful_echo "${BLUE}Installing FVM${WHITE}."
    sh -c "$(curl -fsSL https://fvm.app/install.sh)"

    brew tap leoafarias/fvm
    install_brew_package "fvm"
    add_post_install_instructions "Dart and Flutter" "Run fvm flutter doctor to ensure flutter is working"
    add_post_install_instructions "Dart and Flutter" "Verify the simulator works via 'open -a Simulator' for mac or Android Studio for Android"
    mkdir "${HOME}/.fvm"
    fvm install stable
    fvm global stable
    add_config_to_shells "DART" "export PATH='$HOME/.fvm/bin:$PATH'"
    add_post_install_instructions "Dart and Flutter" "You may want to install more versions of the Dart/Flutter SDK, via fvm install <version>"
    fvm use stable
    fvm flutter doctor --android-licenses
else
    colorful_echo "   • ${YELLOW}FVM already installed${WHITE}."
fi

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# JavaScript
draw_a_line "LINE"
draw_sub_title "Setting up JavaScript"
draw_a_line "LINE"

install_brew_package "node"
if ! command_exists nvm ; then
	mkdir -p "${HOME}/.nvm"
	install_brew_package "nvm"
fi
add_config_to_shells "NVM" <<'EOF'
    export NVM_DIR="~/.nvm"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
EOF
install_brew_package "pnpm"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Java
draw_a_line "LINE"
draw_sub_title "Setting up Java"
draw_a_line "LINE"

install_brew_package "maven"
install_brew_package "gradle"
add_post_install_instructions "Java" "Add your maven settings.xml file to ~/.m2/settings.xml"
add_post_install_instructions "Java" "Add your gradle settings to ~/.gradle/gradle.properties"
add_post_install_instructions "Java" "Verify the JAVA_HOME is set correctly to JAVA_HOME=$JAVA_HOME"

if ! command_exists jenv ; then
    colorful_echo "   • ${BLUE}jEnv installed${WHITE}."
    install_brew_package "jenv"
    add_config_to_shells "jEnv" <<'EOF'
export PATH="~/.jenv/bin:$PATH"
eval "$(jenv init -)"
EOF

fi
add_post_install_instructions "Java" "Add your java installations, and then add them to jEnv using use jenv add."

# Ensure jEnv is installed
if ! command_exists jenv; then
    echo "jEnv is not installed. Please install it first."
    exit 115
fi

# Function to add newly installed JDKs to jEnv
get_jdk_installation_path() {
    global selected_os

    case $selected_os in
        "WSL")
            echo "/usr/lib/jvm" ;; # Typical JDK installation path on Linux
        "Ubuntu")
            echo "/usr/lib/jvm" ;;
        "OSX")
            echo "/Library/Java/JavaVirtualMachines" ;;
        *)
            echo "/usr/lib/jvm" &;; # should never hit this.
    esac
}

# Function to add newly installed JDKs to jEnv
add_new_jdks_to_jenv() {
    local jdk_path

    jdk_path=$(get_jdk_installation_path)
    find "$jdk_path" -type d -name "jdk*" | while read -r path; do
        jenv add "$path"
    done
}

# is OpenJDK installed and managed by jEnv?
is_openjdk_installed_jenv() {
    local version_keyword=$1
    jenv versions --bare | grep -q "$version_keyword"
}

# Function to set jEnv to use the newly installed OpenJDK
set_jenv_version() {
    # Get the installed OpenJDK directory
    latest_jdk=$(ls -td /Library/Java/JavaVirtualMachines/jdk*.jdk | head -n 1)
    if [ -n "$latest_jdk" ]; then
        version_name=$(basename "$latest_jdk" .jdk)
        jenv global "$version_name"
        colorful_echo "   • ${GREEN}Set $version_name as the default Java version using jEnv.${WHITE}"
    else
        echo "Could not find installed JDK."
        exit 112
    fi
}

# Install OpenJDK if not already managed by jEnv
if ! is_openjdk_installed_jenv "1\.[0-9]*" && ! is_openjdk_installed_jenv "temurin"; then
    install_brew_package "openjdk"  # Use Homebrew to manage JDK installations

    # Add installed JDKs to jEnv
    add_new_jdks_to_jenv

    # Set the latest OpenJDK as default
    latest_version=$(jenv versions --bare | grep -E 'openjdk|temurin' | sort -V | tail -n 1)
    if [ -n "$latest_version" ]; then
        jenv global "$latest_version"
        colorful_echo "   • ${GREEN}Set $latest_version as the default Java version using jEnv${WHITE}."
    else
        colorful_echo "   • ${RED}No OpenJDK versions detected by jEnv${WHITE}."
        post_install_instructions "Java" "Script was unable to install OpenJDK. Please install it manually and configur jEnv."
    fi
else
    colorful_echo "   • ${YELLOW}An OpenJDK version is already the default Java managed by jEnv.${WHITE}"
fi
post_install_instructions "Java" "This should have installed the lastest version of OpenJDK. $(java -version)"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Python
draw_a_line "LINE"
draw_sub_title "Setting up Python"
draw_a_line "LINE"

install_brew_package "uv"

if [[ ! -d "${HOME}/.venv" ]]; then
    mkdir "${HOME}/.venv"
fi
# safe to run multiple times
uv python install 3.12

if [[ ! -d "${HOME}/.venv/dev" ]]; then
    uv venv "${HOME}/.venv/dev"
    # shellcheck source=/dev/null
    source "${HOME}/.venv/dev/bin/activate"
    command_exists pre-commit || uv  install pre-commit
fi
if ! command_exists pipx; then
    install_brew_package "pipx"
    pipx ensurepath
fi
add_post_install_instructions "Python" "Add your global python virtualenvs to the ~/.venv folder."
add_post_install_instructions "Python" "Add your any additional global Python packages to the dev enviornment, is already created and set as the default upon login. use 'uv pip install <package>' when dev is active to do so."

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# PHP
draw_a_line "LINE"
draw_sub_title "Setting up PHP"
draw_a_line "LINE"

install_brew_package "php"
install_brew_package "composer"

add_post_install_instructions "PHP" "Add your PHP settings to ~/.php.ini"
add_post_install_instructions "PHP" "Add your composer settings to ~/.composer/composer.json"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Run the os specific script
case $selected_os in
    "WSL")
        bash "${original_dir}/setupscripts/wsl-setup.sh"
        ;;
    "Ubuntu")
        bash "${original_dir}/setupscripts/linux-setup.sh"
        ;;
    "OSX")
        bash "${original_dir}/setupscripts/mac-setup.sh"
        ;;
esac

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Final Steps
draw_a_line "LINE"
draw_sub_title "🎉 Setup complete! Please drive through 🎉"
draw_a_line "LINE"

# Writes out the post instruction to dos to file, and displays them to the user.
write_post_install_instructions
show_post_install_tasks

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# the end.

cd "${original_dir}" || exit 1
exit 0
