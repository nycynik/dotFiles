#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/addfunctions.sh ]] && source ./setupscripts/addfunctions.sh || {
    echo "setup-helpers.sh not found"
    exit 199
}


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Main
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# keychain for ssh agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/github_key
add_config_to_shells "SSH_AGENT" <<'EOF'
# Check if an ssh-agent is already running
if ! pgrep -q ssh-agent; then
  # If not, start a new ssh-agent and save the environment variables to a file
  eval $(ssh-agent -s) > ~/.ssh/ssh-agent-vars
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
  ssh-add --apple-use-keychain ~/.ssh/github_key
else
  # Otherwise, use the existing agent
  if [[ -f ~/.ssh/ssh-agent-vars ]]; then
    source ~/.ssh/ssh-agent-vars
  fi
fi
EOF
post_install_instructions "SSH" "Add your ssh keys to the keychain by running 'ssh-add --apple-use-keychain ~/.ssh/<id>' for any additional keys"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# tools
install_brew_package "rectangle"
install_brew_package "qlmarkdown"
install_brew_package "qlcolorcode"
install_brew_package "wget"

post_install_instructions "Tools" "Install Rectangle, QLMarkdown, QLColorCode, they are added to the Applications folder, but need to be opened and approved to use."


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Ruby
install_brew_package "ruby"
add_config_to_shells "RUBY" <<'EOF'
export PATH="/usr/local/opt/ruby/bin:$PATH"
EOF
post_install_instructions "Ruby" "Ruby is set up, this only updated the version of ruby to the latest. $(ruby -v)"
post_install_instructions "Ruby" "You may want to install bundler. Run 'gem install bundler'"


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
if ! command_exists pod; then
    colorful_echo "   • Installing CocoaPods${WHITE}."
    sudo gem install cocoapods
    add_config_to_shells "COCOAPODS" <<'EOF'
export PATH="~/.gem/bin:$PATH"
EOF

fi

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
colorful_echo "   • ${GREEN}Finished MacOS Setup${WHITE}."
