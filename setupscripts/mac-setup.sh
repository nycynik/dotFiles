#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/add-functions.sh ]] && source ./setupscripts/add-functions.sh || {
    echo "add-functions.sh not found"
    exit 199
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
#   MAiN
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# keychain for ssh agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/github_key
add_config_to_shells "SSH_AGENT" <<'EOF'
eval "$(ssh-agent -s)" > /dev/null
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


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Ruby
add_post_install_instructions "Ruby" "Ruby is set up, this only updated the version of ruby to the latest. $(ruby -v)"
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
