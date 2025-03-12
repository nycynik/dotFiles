#!/bin/bash

# Let's get some fun color and stuff!
if [[ -f "${HOME}/scripts/prettyfmt.sh" ]]; then
    source"${HOME}/scripts/prettyfmt.sh"
else
    echo "⛔ Could not find ~/scripts/prettyfmt.sh. Exiting..."
    exit 1
fi

# get the functions
if [[ -f "${HOME}/.dotfiles/functions" ]]; then
    source "${HOME}/.dotfiles/functions"
else
    echo "⛔ Could not find ~/.dotfiles/functions. Exiting..."
    exit 1
fi

draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# mac os dev tools and apps
command_exists betterzip || brew install betterzip 2>&1 | tee -a "${brew_log:?}"
command_exists wget || brew install wget 2>&1 | tee -a "${brew_log:?}"
command_exists stats || brew install stats 2>&1 | tee -a "${brew_log:?}"

# java
if ! command_exists java || ! command_exists javac; then
    echo "Installing OpenJDK..."
    brew install openjdk | tee -a "${brew_log}"

    # After installation, you might need to link it
    sudo ln -sfn "$(brew --prefix)"/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

# Dart
# if ! command_exists dart; then
#     colorful_echo "Installing Dart..."
#     brew tap dart-lang/dart
#     brew install dart 2>&1 | tee -a "${brew_log}"
# fi

# IDEs
command_exists code || brew install --cask visual-studio-code
command_exists android-studio || brew install --cask android-studio

# window tools
command_exists rectangle || brew install --cask rectangle 2>&1 | tee -a "${brew_log}"

# xcode
if ! command_exists xcode-select; then
    colorful_echo "Installing Xcode..."
    # command_exists xcode-select || xcode-select --install
    sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
    sudo xcodebuild -license
    xcodebuild -downloadPlatform iOS
fi
# cocopods
if ! command_exists pod; then
    colorful_echo "Installing Cocoapods..."
    sudo gem install cocoapods
    echo 'export PATH="$HOME/.gem/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="$HOME/.gem/bin:$PATH"' >> ~/.zshrc
fi


echo "Finished Setup"
