#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/add-functions.sh ]] && source ./setupscripts/add-functions.sh || {
    echo "add-functions.sh not found"
    exit 199
}
BOX_WIDTH=80
export BOX_WIDTH

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
#   MAiN
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Bash
cat <<EOT >> ~/.bash_profile
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
EOT

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# keychain for ssh agent
colorful_echo "   • ${GREEN}Adding ssh keys to keychain${WHITE}."
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/github_key

replace_config_in_file "SSH-GITHUB" "${HOME}/.ssh/config" << 'EOF'
Host github.com
  HostName github.com
  User git
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/github_key
  IdentitiesOnly yes
  ForwardX11 no
EOF


replace_config_in_shells "SSHKEYS" <<'EOF'
# MacOS Specific Version to use keychain.
# Start SSH Agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Automatically add keys if they are not already loaded
if ! ssh-add -l > /dev/null 2>&1; then
    ssh-add --apple-use-keychain ~/.ssh/github_key ~/.ssh/id_ed25519 2>/dev/null
fi
EOF

add_post_install_instructions "SSH" "Add your ssh keys to the keychain by running 'ssh-add --apple-use-keychain ~/.ssh/<id>' for any additional keys"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# tools
install_brew_package "rectangle"
install_brew_package "qlmarkdown"
install_brew_package "qlcolorcode"
install_brew_package "wget"
install_brew_package "bash" # upgrade to the latest bash, OSX is lagging, so this is needed.

add_post_install_instructions "Tools" "Install Rectangle, QLMarkdown, QLColorCode, they are added to the Applications folder, but need to be opened and approved to use."

# Docker
if [[ ! -d "/Applications/Docker.app" ]]; then
    # if not manually installed.
    install_brew_package "docker"
fi
add_post_install_instructions "Tools" "You may need to launch Docker and approve it to run."
mkdir -p ~/.oh-my-zsh/completions
add_post_install_instructions "Tools" "once you approve docker you can then run docker completion zsh > ~/.oh-my-zsh/completions/_docker"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Ruby
add_post_install_instructions "Ruby" "Ruby is set up, this only updated the version of ruby to the latest."
add_post_install_instructions "Ruby" "You may want to install bundler. Run 'gem install bundler'"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Terminal (iTerm2)

# Function to apply iTerm2 preferences
apply_iterm2_preferences() {
    local ITERM2_PREFS_SRC="./tempates/com.googlecode.iterm2.plist"
    local ITERM2_PREFS_DST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

    if [ -f "$ITERM2_PREFS_SRC" ]; then
        cp "$ITERM2_PREFS_SRC" "$ITERM2_PREFS_DST"
        colorful_echo "   • ${BLUE}Applied iTerm2 preferences from $ITERM2_PREFS_SRC{$WHITE}."
    else
        colorful_echo "   • ${YELLOW}iTerm2 preferences file not found at $ITERM2_PREFS_SRC. Skipping${WHITE}."
    fi
}
# Install iTerm2 & Prefs
install_brew_package "iterm2"
apply_iterm2_preferences
add_post_install_instructions "Tools" "You may need to launch iTerm2 and approve it to run."

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# IDEs
if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
    install_brew_package "visual-studio-code"
fi
# TODO: Add extensions or log in and sync
# TODO: Add settings.json manipulations
# TODO: Workspace settings - add "terminal.integrated.defaultProfile.linux": "bash", "terminal.integrated.defaultProfile.windows": "Git Bash", // or another bash-like shell in Windows "terminal.integrated.defaultProfile.osx": "bash"

# Intellij
# if [[ ! -d "/Applications/IntelliJ IDEA.app" ]]; then
#     install_brew_package "intellij-idea"
# fi

# Android Studio
if [[ ! -d "/Applications/Android Studio.app" ]]; then
    install_brew_package "android-studio"
fi
# xcode
if ! command_exists xcode-select; then
    colorful_echo "  Installing Xcode..."
    # command_exists xcode-select || xcode-select --install
    sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
    sudo xcodebuild -license
    xcodebuild -downloadPlatform iOS
fi
if [[ ! -d "/Applications/DBeaver.app" ]]; then
    install_brew_package "dbeaver-community"
fi

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# iOS/Flutter
add_post_install_instructions "Flutter" "install cocoapods with gem install cocoapods after activating the latest ruby"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
colorful_echo "   • ${GREEN}Finished MacOS Setup${WHITE}."
