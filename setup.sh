#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/add-functions.sh ]] && source ./setupscripts/add-functions.sh || {
    echo "add-functions.sh not found, can't recover"
    exit 199
}
BOX_WIDTH=80
export BOX_WIDTH

showScreen() {
  clear
  draw_title "${1:-Welcome to your new home setup!}"
}

showInstallationPart() {
    local word="${1:-'dotFiles'}"
    local description="${2:-'Setting up your dotfiles'}"

    draw_a_line "LINE"
    # if figlet is defined, use it
    if command_exists figlet; then
        # this is when I realized I was having way too much fun.
        # Define an array of colors
        local colors=("${CYAN}" "${CYAN}" "${LIGHT_CYAN}" "${WHITE}" "${LIGHT_CYAN}" "${CYAN}" "${CYAN}" "${CYAN}" )
        local color_count=${#colors[@]}  # Get the number of colors
        local line_index=0

        figlet_output=$(figlet -f graffiti "${word}")
        while IFS= read -r line; do
            # Calculate padding for centering
            padding=$(( ($BOX_WIDTH - ${#line}) / 2 ))
            current_color="${colors[$((line_index % color_count))]}"
            printf "%*s${BOLD}${current_color}%s${NC}\n" "$padding" "" "$line"
            ((line_index++))
        done <<< "$figlet_output"
    else
        draw_title "${word}"
    fi
    draw_a_line "LINE"
    draw_sub_title "${description}"
}

# global variables
original_dir=$(pwd)

## ---------------------------
## Main script
## ---------------------------

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Basic setup steps
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
setup_step_verify_launch_folder() {

    # verify we are in the right directory
    if [[ "${original_dir}" != "${HOME}" ]] ; then
        echo "NOTE: script is not running from your home dir. (HOME set to $HOME)"
        if [ ! -L ~/.dotfiles ]; then
            read -sp "Create symlink from home to ${PWD} [Y/n]? " -n 1 -r
            if [[ "$REPLY" =~ ^[yY]$ ]] ; then
                ln -s "${PWD}" ~/.dotfiles
            else
                echo "⛔ Could not run from another directory without a symlink to this one. Exiting..."
                exit 120
            fi
        fi
    fi
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Interactive section
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------

gather_user_settings() {

    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # OS Selection
    showScreen "dotFiles / Setup / OS Selection"

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
    read -n 1 -rp "Which OS [1-4, or enter for $detected_os]: " choice

    selected_os=""
    # If the user presses Enter without entering anything, the choice variable will be empty
    if [[ -z "$choice" ]]; then
        colorful_echo "\n\nProceeding with the default detected OS: $detected_os"
        selected_os=$detected_os
    elif [[ "$choice" =~ ^[1-3]$ ]]; then
        colorful_echo "\n\nYou chose option ${BLUE}${choice}"
        declare -A os_types=(
            [1]="WSL"
            [2]="Ubuntu"
            [3]="OSX"
        )
        selected_os=${os_types[$choice]}
    elif [[ "$choice" == "4" ]]; then
        colorful_echo "\n\n${YELLOW}Exiting without making any changes. Have a nice day!"
        exit 0
    else
        colorful_echo "\n\n⛔ ${RED}Invalid choice.${YELLOW} Exiting..."
        exit 1
    fi

    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Gather Info
    showScreen "dotFiles / Setup / OS Selection"

    username=""
    email=""

    # if git exists, we can load the username and email from there.
    if command_exists git; then
        username=$(git config --global user.name)
        email=$(git config --global user.email)
    fi

    colorful_echo "${WHITE}Let's set up your name for github and other services.\n"

    read -rp "$(echo -e "${BLUE}"Full Name "${GREEN}"["${YELLOW}""$username""${GREEN}"]"${WHITE}":"${GREEN}")" USERNAME
    USERNAME="${USERNAME:-$username}"  # Use $username as default if USERNAME is empty

    read -rp "$(echo -e "${BLUE}Email" "${GREEN}"["${YELLOW}""$email""${GREEN}"]"${WHITE}":"${GREEN}")" USEREMAIL
    USEREMAIL="${USEREMAIL:-$email}"

    # generate a random passphrase
    PASSPHRASE=$(openssl rand -base64 32)
    read -srp "$(echo -e "${BLUE}Passphrase" "${GREEN}[${YELLOW}${PASSPHRASE}${GREEN}]${WHITE}:${GREEN}")" PASSPHRASE
    PASSPHRASE="${PASSPHRASE:-supersecurepassphrase}"
    PASSPHRASE=$(echo "$PASSPHRASE" | tr -d '\n')  # Remove newlines from the passphrase
    passphrase_length=${#PASSPHRASE}
    printf "%${passphrase_length}s\n" | tr ' ' '🔑'

    # get default development folder, defaults to ~/dev
    DEV_FOLDER=~/dev
    read -rp "$(echo -e "${BLUE}Dev Folder" "${GREEN}[${YELLOW}${DEV_FOLDER}${GREEN}]${WHITE}:${GREEN}")" DEV_FOLDER
    DEV_FOLDER="${DEV_FOLDER:-~/dev}"

    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Confirm Info
    showScreen "dotFiles / Setup / Confirmation"

    pk10_status="${GREEN}Installed"
    if [[ -d "$HOME/.oh-my-zsh" ]] ; then
        pk10_status="${YELLOW}Skipping, already installed"
    fi
    hb_status="${GREEN}Installed"
    if [[ -d "/opt/homebrew" ]] ; then
        hb_status="${YELLOW}Skipping, already installed"
    fi
    git_status="${GREEN}Installed"
    if command_exists git ; then
        git_status="${YELLOW}Skipping, already installed"
    fi

    echo ""
    colorful_echo "${BLUE}Please confirm your settings\n"
    colorful_echo " 🖥️  ${BLUE}OS Selected${WHITE}: ${GREEN}${selected_os}"
    colorful_echo " 📬    ${BLUE}User Info${WHITE}: ${GREEN}${USERNAME} <${USEREMAIL}>"
    colorful_echo " 🏠  ${BLUE}Home Folder${WHITE}: ${GREEN}${HOME}"
    colorful_echo " 📁   ${BLUE}Dev Folder${WHITE}: ${GREEN}${DEV_FOLDER}"
    colorful_echo " 📜 ${BLUE}        P10k${WHITE}: ${pk10_status}"
    colorful_echo " 🍺 ${BLUE}    Homebrew${WHITE}: ${hb_status}"
    colorful_echo " 🐙 ${BLUE}         Git${WHITE}: ${git_status}"

    echo -en "\n👋 ${WHITE}Are you ready to run first time setup? ${GREEN}[y/N]${NC}"
    read -n 1 -sr response

    if [[ $response =~ ^[Yy]$ ]]
    then
        colorful_echo "\n\n${BLUE}Great${WHITE}! ${GREEN}Let's begin the setup process${WHITE}.\n"
    else
        colorful_echo "\n\n${YELLOW}Setup cancelled${WHITE}. \n${BLUE}You can run this script again when you're ready${WHITE}."
        [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
}

setup_identity() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Setup Identity
    showInstallationPart "Identity" "Setting up Identity"

    install_brew_package "gnupg"
    if ! command -v gpg >/dev/null 2>&1; then
        colorful_echo "   • ${RED}GPG failed to install${WHITE}."
        exit 112
    fi

    if [[ ! -d "${HOME}/.gnupg" ]]; then
        mkdir "${HOME}/.gnupg"
        chown -R "$(whoami)" "${HOME}/.gnupg"
        chmod 700 "${HOME}/.gnupg"

        # find ~/.gnupg -type f -exec chmod 600 {} \; # Set 600 for files
        # find ~/.gnupg -type d -exec chmod 700 {} \; # Set 700 for directories

        colorful_echo "   • ${BLUE}Created ${GREEN}~/.gnupg${WHITE}."
    fi

    # check if gpg keys already exist for this user, if not generate them.
    if ! gpg --list-keys "${USEREMAIL}" &>/dev/null; then
        # we need to generate a key
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

        echo "$GPG_BATCH_CONTENT" | gpg --batch --generate-key
        colorful_echo "   • ${BLUE}Created GPG key${WHITE}."
    else
        colorful_echo "   • ${YELLOW}GPG key already exists. Skipping creation.${WHITE}."
    fi

    add_config_to_shells "GNUPG" <<'EOT'
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent
EOT

    # storing this for git setup later (needed if we just made it or not)
    gpgkey=$(gpg --list-secret-keys --keyid-format LONG "$USEREMAIL" | awk -F' ' '/sec/{print $2}' | awk -F'/' '{print $2}' | head -n 1)
    add_post_install_instructions "Identity" "Add your GPG key to github.com using gpg --armor --export $gpgkey"
}

setup_shell() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Setup Shell
    showInstallationPart "Shell" "Setting up your shell and environment"

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

    # create the post install file for this run
    init_post_install_tasks

    if [[ ! -d "${HOME}/bin/" ]]; then
        mkdir "${HOME}/bin"
        colorful_echo "   • ${BLUE}Created bin folder${WHITE}.\n"
    fi
    add_config_to_shells "PERSONAL-BIN" <<'EOF'
# include my personal bin folder in the Path
if [ -d "~/bin/" ]; then
    export PATH=$PATH:~/bin
fi
EOF

    if [[ ! -d "${HOME}/scripts/" ]]; then
        mkdir "${HOME}/scripts"
        cp -Rf ./scripts/* "$HOME/scripts/"
        colorful_echo "   • ${BLUE}Created scripts folder${WHITE}."
    fi

    if [[ ! -d "${DEV_FOLDER}" ]]; then
        mkdir -p "${DEV_FOLDER}"
        colorful_echo "   • ${BLUE}Created Default dev folder at ${DEV_FOLDER}${WHITE}."
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
    add_config_to_shells "SOURCES" <<'EOF'
    if [[ -f ~/.dotfiles/aliases ]]; then source ~/.dotfiles/aliases; fi
    if [[ -f ~/.dotfiles/functions ]]; then source ~/.dotfiles/functions; fi
EOF

    # bash completion
    install_brew_package "bash-completion"
    if [[ ! -d "$HOME/.bash_completion.d" ]]; then
        mkdir "$HOME/.bash_completion.d"
        colorful_echo "   • ${BLUE}Created ${GREEN}~/.bash_completion.d${WHITE}."
    fi
    # add only to .bash_profile, so we dont' use add_config_to_shells
    add_config_to_file "BASH-COMPLETION" "${HOME}/.bash_profile" <<'EOF'
if [ -d ~/.bash_completion.d ]; then
    for file in ~/.bash_completion.d/*; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
    done
fi
EOF

    # ------------
    # SSH Config
    if [[ ! -d "$HOME/.ssh" ]]; then
        mkdir "$HOME/.ssh"
        colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh${WHITE}."
    fi
    if [[ ! -f "$HOME/.ssh/config" ]]; then
        touch "$HOME/.ssh/config"
        printf "# SSH CONFIG\n\n# Include ~/.ssh/localservers\n" >> "${HOME}/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/config${WHITE}."
    fi

    # ssh-agent key setup
    eval "$(ssh-agent -s)" > /dev/null
    add_config_to_shells "SSHKEYS" <<'EOF'
# Start SSH Agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Automatically add keys if they are not already loaded
if ! ssh-add -l > /dev/null 2>&1; then
    ssh-add ~/.ssh/github_key ~/.ssh/id_ed25519 2>/dev/null
fi
EOF

    # create keys if they don't exist
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        ssh-keygen -t ed25519 -C "$USEREMAIL" -f "$HOME/.ssh/id_ed25519"
        ssh-add ~/.ssh/id_ed25519
        colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/id_rsa${WHITE}."
    fi

    replace_config_in_file "SSH-ALL-SITES" "${HOME}/.ssh/config" <<'EOF'
Host *
  ForwardAgent yes
  ForwardX11 yes
  VisualHostKey yes
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
EOF

    if [[ ! -f "$HOME/.ssh/github_key" ]]; then
        ssh-keygen -t ed25519 -C "$USEREMAIL" -f "$HOME/.ssh/github_key"
        ssh-add ~/.ssh/github_key

        add_post_install_instructions "SSH" "Add your SSH keys for git to github.com (pbcopy < ~/.ssh/github_key on mac) https://github.com/settings/keys "
        colorful_echo "   • ${BLUE}Created ${GREEN}~/.ssh/github_key${WHITE}."
    fi
    replace_config_in_file "SSH-GITHUB" "${HOME}/.ssh/config" << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_key
  IdentitiesOnly yes
  ForwardX11 no
EOF
}

setup_homebrew() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Setup Homebrew
    showInstallationPart "Homebrew" "Setting up Homebrew for you"

    if ! command_exists brew; then

        if ! command_exists curl; then
            echo "curl must be installed to install brew."
            if command_exists apt; then
                sudo apt update && sudo apt upgrade
                sudo apt install curl
            elif command_exists yum; then
                yum install curl
            elif command_exists pacman; then
                pacman -S curl
            else
                colorful_echo "   • ${RED}curl not installed, and no package manager found to install it.${WHITE}"
                exit 2  
            fi
        fi

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
    add_post_install_instructions "Homebrew" "You may need to open a new terminal for some settings to take effect."
    add_post_install_instructions "Homebrew" "You should review the brew installation logs at $(brew_get_brew_log_path)"
    add_post_install_instructions "Homebrew" "brew doctor was run, and you are ready to brew, but you may want to run it again and see if there were any warnings or to-dos."

    # if tee is not isntalled, isntall it with brew.
    if ! command_exists tee; then
        brew install tee # can't use function for this one, because function requres tee.
        colorful_echo "   • ${BLUE}Installed ${GREEN}tee${WHITE}."
    fi
}

setup_dev_tools() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Dev tools
    showInstallationPart "Tools" "Setting up dev tools and commands"

    # dev tools
    install_brew_package "watchman"
    install_brew_package "httpie"
    install_brew_package "curl"
    install_brew_package "tree"
    install_brew_package "jq"
    install_brew_package "eza"
    install_brew_package "shellcheck"
    install_brew_package "fzf"
    install_brew_package "gawk"
    install_brew_package "figlet"           # draws words

    add_post_install_instructions "Tools" "Add vscode to the command line. Launch vscode, c-a-P 'term' and then click add it. If there are any issues, you may need to remove /usr/bin/local/code first."

    # asdf
    install_brew_package "asdf"
    add_config_to_shells "ASDF" <<'EOF'
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
. $(brew --prefix asdf)/libexec/asdf.sh
EOF

}

# Description:
#   Sets up git. This is safe to call twice, but will override all the git
#   settings that are configured here.
#   * Creates .gitconfig if it does not exist
#   * Sets up global config
#   * Creates .gitignore_global
#   * Creates, or adds global git-hooks to include pre-commit.
#
# Usage:
#   setup_git
setup_git() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Setup Git
    showInstallationPart "Git" "Setting up Git and configuring it"

    install_brew_package "git"

    # setup gitconfig
    tagFile "$HOME/.gitconfig"
    # Add all the config
    # Core settings
    git config --global core.editor "nano"
    git config --global core.excludesfile "${HOME}/.gitignore_global"
    git config --global core.hooksPath "${HOME}/.git-hooks"

    # Aliases
    git config --global alias.br "branch"
    git config --global alias.ci "commit -S"
    git config --global alias.cia "commit -Sa"
    git config --global alias.cd "commit -S --amend"
    git config --global alias.cad "commit -S --amend --no-edit"
    git config --global alias.co "checkout"
    # shellcheck disable=SC2016
    git config --global alias.co-push '!f() { git checkout -b $1; git push --set-upstream ${2:-origin} $1; }; f'
    git config --global alias.dump "cat-file -p"
    git config --global alias.fixup "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup"
    git config --global alias.h "!git log --oneline --decorate --all"
    git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.ls "ls-files"
    git config --global alias.lsf "!git ls-files | grep -i"
    git config --global alias.p "pull --rebase"
    git config --global alias.st "status"
    git config --global alias.ss "status -s"
    git config --global alias.type "cat-file -t"

    # Delta settings
    git config --global delta.features "line-numbers decorations"
    git config --global delta.line-numbers "true"

    # Help settings (100th of seconds 5=.5s, 10=1s)
    git config --global help.autoCorrect "20"

    # Init settings
    git config --global init.defaultBranch "main"

    # setup gpg
    git config --global commit.gpgsign true
    git config --global gpg.program gpg

    # setup user info
    git config --global user.signingkey "$gpgkey"
    git config --global user.name "$USERNAME"
    git config --global user.email "$USEREMAIL"

    colorful_echo "   • ${GREEN}Setup git aliases{$WHITE}."

    tagFile "$HOME/.gitignore_global"
    replace_config_in_file "GITIGNORE" "$HOME/.gitignore_global" <<'EOF'
# Mac
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
.AppleDouble
.LSOverride

# Win
Desktop.ini
ehthumbs.db
Thumbs.db
EOF
    colorful_echo "   • ${GREEN}Setup global git ignore{$WHITE}."


    # githooks
    if [[ ! -d "${HOME}/.git-hooks" ]]; then
        mkdir -p "${HOME}/.git-hooks"
        cp ./templates/pre-commit "${HOME}/.git-hooks/pre-commit"
        chmod +x "${HOME}/.git-hooks/pre-commit"
    fi

    colorful_echo "   • ${GREEN}Setup git hooks{$WHITE}."

    # GitHub CLI Setup
    install_brew_package "gh" # github CLI

    gh config set editor code

    # gh aliases
    gh alias set bugs 'issue list --label=bugs'
    gh alias set 'issue mine' 'issue list --mention @me'
    gh alias set homework 'issue list --assignee @me'
    gh alias set 'issue mine --open' 'issue list --mention @me --state open'
    gh alias set homework-open 'issue list --assignee @me --state open'

    colorful_echo "   • ${GREEN}Setup GitHub CLI{$WHITE}."

    add_post_install_instructions "git" "authenticate with github CLI using 'git auth login'"
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Flutter
setup_flutter() {
    showInstallationPart "Flutter" "Setting up Flutter and Dart"

    # Dart & Flutter
    if ! command_exists fvm; then
        colorful_echo "${BLUE}Installing FVM${WHITE}."
        sh -c "$(curl -fsSL https://fvm.app/install.sh)"

        brew tap leoafarias/fvm
        install_brew_package "fvm"
        add_post_install_instructions "Flutter" "Run fvm flutter doctor to ensure flutter is working"
        add_post_install_instructions "Flutter" "Verify the simulator works via 'open -a Simulator' for mac or Android Studio for Android"
        fvm install stable
        fvm global stable
        add_post_install_instructions "Flutter" "You may want to install more versions of the Dart/Flutter SDK, via fvm install <version>"
        fvm use stable
        fvm flutter doctor --android-licenses
    else
        colorful_echo "   • ${YELLOW}FVM already installed${WHITE}."
    fi
    add_config_to_shells "DART" <<'EOF'
export PATH="~/fvm/default/bin:$PATH"
EOF
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# JavaScript
setup_javascript() {

    showInstallationPart "JavaScript" "Setting up JavaScript for you"

    # install standalone pnpm
    if ! command_exists pnpm; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        add_post_install_instructions "pnpm" "pnpm env use --global lts"
        colorful_echo "   • ${GREEN}Installed pnpm${WHITE}."
    fi

    # install asdf plugin for nodejs if it's not installed, update otherwise
    if asdf plugin list | grep -q nodejs; then
        colorful_echo "   • ${BLUE}Updating asdf nodejs plugin${WHITE}."
        asdf plugin update nodejs
    else
        colorful_echo "   • ${BLUE}Installing asdf nodejs plugin${WHITE}."
        asdf plugin add nodejs
        # asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    fi
    # using asdf install latest version of node, if no node version installed by asdf yet
    if asdf list nodejs | grep -q "No installed versions found"; then
        colorful_echo "   • ${BLUE}Installing latest nodejs version${WHITE}."
        asdf install nodejs latest
    else
        colorful_echo "   • ${YELLOW}Skipping installing latest nodejs${WHITE}."
    fi
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Java
setup_java() {
    showInstallationPart "Java" "Setting up Java for you"

    install_brew_package "maven"
    install_brew_package "gradle"
    add_post_install_instructions "Java" "Add your maven settings.xml file to ~/.m2/settings.xml"
    add_post_install_instructions "Java" "Add your gradle settings to ~/.gradle/gradle.properties"
    add_post_install_instructions "Java" "Verify the JAVA_HOME is set correctly to JAVA_HOME=$JAVA_HOME"

    if ! command_exists jenv ; then
        colorful_echo "   • ${BLUE}jEnv installed${WHITE}."
        install_brew_package "jenv"
    fi
    add_config_to_shells "jEnv" <<'EOF'
export PATH="~/.jenv/bin:$PATH"
eval "$(jenv init -)"
EOF

    add_post_install_instructions "Java" "Add your java installations, and then add them to jEnv using use jenv add."

    # Ensure jEnv is installed
    if ! command_exists jenv; then
        echo "jEnv is not installed. Please install it first."
        exit 115
    fi

    # Function to add newly installed JDKs to jEnv
    get_jdk_installation_path() {

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
        latest_jdk="$(ls -td /Library/Java/JavaVirtualMachines/jdk*.jdk | head -n 1)"
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
        install_brew_package "temurin"

        # Add installed JDKs to jEnv
        add_new_jdks_to_jenv

        # Set the latest OpenJDK as default
        latest_version=$(jenv versions --bare | grep -E 'temurin' | sort -V | tail -n 1)
        if [ -n "$latest_version" ]; then
            jenv global "$latest_version"
            colorful_echo "   • ${GREEN}Set $latest_version as the default Java version using jEnv${WHITE}."
        else
            colorful_echo "   • ${RED}No OpenJDK versions detected by jEnv${WHITE}."
            add_post_install_instructions "Java" "Script was unable to install OpenJDK. Please install it manually and configur jEnv."
        fi
    else
        colorful_echo "   • ${YELLOW}An OpenJDK version is already the default Java managed by jEnv.${WHITE}"
    fi
    add_post_install_instructions "Java" "This should have installed the lastest version of OpenJDK. $(java -version)"
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Python
setup_python() {
    showInstallationPart "Python" "Setting up Python for you"

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
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# PHP
setup_php() {
    showInstallationPart "PHP" "Setting up PHP for you"

    install_brew_package "php"
    install_brew_package "composer"

    add_post_install_instructions "PHP" "Add your PHP settings to ~/.php.ini"
    add_post_install_instructions "PHP" "Add your composer settings to ~/.composer/composer.json"
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Ruby
setup_ruby() {
    showInstallationPart "Ruby" "Setting up Ruby for you"

    # install asdf plugin for nodejs if it's not installed, update otherwise
    if asdf plugin list | grep -q nodejs; then
        colorful_echo "   • ${BLUE}Updating asdf nodejs plugin${WHITE}."
        asdf plugin update ruby
    else
        colorful_echo "   • ${BLUE}Installing asdf nodejs plugin${WHITE}."
        asdf plugin add ruby
        install_zsh_plugin "https://github.com/asdf-vm/asdf.git"
    fi
    if asdf list ruby | grep -q "No installed versions found"; then
        colorful_echo "   • ${BLUE}Installing latest ruby version${WHITE}."
        asdf install ruby latest
    else
        colorful_echo "   • ${YELLOW}Skipping installing latest ruby${WHITE}."
    fi
    add_config_to_shells "RUBY" <<'EOF'
export PATH="~/.gem/bin:$PATH"
EOF
}

run_os_specific_script() {
    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # Run the OS-specific script
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
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Final Steps
final_steps() {

    draw_a_line "LINE"
    draw_sub_title "🎉 Setup complete - Please drive through 🎉"
    draw_a_line "LINE"

    # Writes out the post instruction to dos to file, and displays them to the user.
    write_post_install_instructions
    show_post_install_tasks

    # --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
    # the end.

    cd "${original_dir}" || exit 1
    exit 0
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Main function
main() {
    # setup for the script
    setup_step_verify_launch_folder

    # get and review user selections
    gather_user_settings

    # various installations and configurations
    setup_homebrew      # Homebrew (must be first, used by all the rest)
    setup_identity      # gnupgp
    setup_shell         # Shell config
    setup_dev_tools     # various command line tools
    setup_git           # git

    # Languages
    draw_title "Language Setup"
    setup_flutter       # Flutter
    setup_javascript    # JavaScript
    setup_java          # Java
    setup_python        # Python
    setup_php           # PHP
    setup_ruby          # Ruby

    # OS Specific script per os supported
    draw_title "OS Specific Setup"
    run_os_specific_script

    # Congratulations and such.
    final_steps
}

# Run main!
main "$@"
