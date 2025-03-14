#!/bin/bash

brew_log="${brew_log:-brew.log}"
marker="# DOTFILES - DO NOT REMOVE THIS LINE"

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

# tools
brew ls --versions rectangle --cask > /dev/null || brew install --cask rectangle 2>&1 | tee -a "${brew_log}"
brew ls --versions qlmarkdown --cask > /dev/null || brew install --cask qlmarkdown 2>&1 | tee -a "${brew_log}"
brew ls --versions qlcolorcode --cask > /dev/null || brew install --cask qlcolorcode 2>&1 | tee -a "${brew_log}"


# Ruby
if ! command_exists ruby; then
    colorful_echo "Installing Ruby..."
    brew install ruby 2>&1 | tee -a "${brew_log:?}"
fi
if ! grep -q "${marker}-RUBY" ~/.zshrc ; then
    printf "\n${marker}-RUBY\nexport PATH='/usr/local/opt/ruby/bin:\$PATH'" >> ~/.zshrc
fi
if ! grep -q "${marker}-RUBY" ~/.bash_profile ; then
    printf "\n${marker}-RUBY\nexport PATH='/usr/local/opt/ruby/bin:\$PATH'" >> ~/.bash_profile
fi

# mac os dev tools and apps
command_exists wget || brew install wget 2>&1 | tee -a "${brew_log:?}"

# java
if ! command_exists java || ! command_exists javac; then
    echo "Installing OpenJDK..."
    install_brew_package openjdk

    # After installation, you might need to link it
    sudo ln -sfn "$(brew --prefix)"/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
else
    colorful_echo "   • ${YELLOW}Java already installed, updating${WHITE}."
fi

# IDEs
if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
    colorful_echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code 2>&1 | tee -a "${brew_log}"
fi
if [[ ! -d "/Applications/Android Studio.app" ]]; then
    colorful_echo "Installing Android Studio..."
    brew install --cask android-studio 2>&1 | tee -a "${brew_log}"
fi
# xcode
if ! command_exists xcode-select; then
    colorful_echo "Installing Xcode..."
    # command_exists xcode-select || xcode-select --install
    sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
    sudo xcodebuild -license
    xcodebuild -downloadPlatform iOS
fi
if [[ ! -d "/Applications/DBeaver.app" ]]; then
    colorful_echo "Installing DBeaver..."
    brew install --cask dbeaver-community 2>&1 | tee -a "${brew_log}"
fi


# cocopods
if ! command_exists pod; then
    colorful_echo "Installing Cocoapods..."
    sudo gem install cocoapods
    echo 'export PATH="~/.gem/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="~/.gem/bin:$PATH"' >> ~/.zshrc
fi


echo "Finished Setup"
