#!/bin/bash

brew_log="${brew_log:-brew.log}"

# Let's get some fun color and stuff!
if [[ -f "${HOME}/scripts/prettyfmt.sh" ]]; then
    source "${HOME}/scripts/prettyfmt.sh"
else
    colorful_echo "⛔ Could not find ${GREEN}~/scripts/prettyfmt.sh${WHITE}. ${YELLOW}Exiting${WHITE}..."
    exit 1
fi

# load the functions
if [[ -f "${HOME}/.dotfiles/functions" ]]; then
    source "${HOME}/.dotfiles/functions"
else
    colorful_echo "⛔ Could not find ${GREEN}~/.dotfiles/functions${WHITE}. ${YELLOW}Exiting${WHITE}..."
    exit 1
fi

draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# mac os dev tools and apps
command_exists wget || brew install wget 2>&1 | tee -a "${brew_log:?}"
brew ls --versions visual-studio-code --cask > /dev/null || brew install --cask stats 2>&1 | tee -a "${brew_log:?}"

# java
if ! command_exists java || ! command_exists javac; then
    echo "Installing OpenJDK..."
    install_brew_package openjdk

    # After installation, you might need to link it
    sudo ln -sfn "$(brew --prefix)"/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

# IDEs
brew ls --versions visual-studio-code --cask > /dev/null || brew install --cask visual-studio-code
brew ls --versions android-studio --cask > /dev/null || brew install --cask android-studio
# xcode
if ! command_exists xcode-select; then
    colorful_echo "Installing Xcode..."
    # command_exists xcode-select || xcode-select --install
    sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
    sudo xcodebuild -license
    xcodebuild -downloadPlatform iOS
fi

# tools
brew ls --versions rectangle --cask > /dev/null || brew install --cask rectangle 2>&1 | tee -a "${brew_log}"
brew ls --versions qlmarkdown --cask > /dev/null || brew install --cask qlmarkdown 2>&1 | tee -a "${brew_log}"

# cocopods
if ! command_exists pod; then
    colorful_echo "Installing Cocoapods..."
    sudo gem install cocoapods
    echo 'export PATH="$HOME/.gem/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="$HOME/.gem/bin:$PATH"' >> ~/.zshrc
fi


echo "Finished Setup"
