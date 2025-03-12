#!/bin/bash

# Let's get some fun color and stuff!
if [[ -f ~/scripts/prettyfmt.sh ]]; then
    source ~/scripts/prettyfmt.sh
else
    echo "⛔ Could not find ~/scripts/prettyfmt.sh. Exiting..."
    exit 1
fi

# get the functions
if [[ -f ~/.dotfiles/functions ]]; then
    source ~/.dotfiles/functions
else
    echo "⛔ Could not find ~/.dotfiles/functions. Exiting..."
    exit 1
fi

draw_a_line "LINE"
draw_sub_title "Mac OS Setup"
draw_a_line "LINE"

# mac os dev tools and apps
command_exists betterzip || brew install betterzip 2>&1 | tee -a "${brew_log}"
command_exists wget || brew install wget 2>&1 | tee -a "${brew_log}"
command_exists stats || brew install stats 2>&1 | tee -a "${brew_log}"

# java
if ! command_exists java || ! command_exists javac; then
    echo "Installing OpenJDK..."
    brew install openjdk | tee -a "${brew_log}"
    
    # After installation, you might need to link it
    sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

# Dart
if ! command_exists dart; then
    colorful_echo "Installing Dart..."
    brew tap dart-lang/dart 
    brew install dart 2>&1 | tee -a "${brew_log}"
fi

# window tools
command_exists rectangle || brew install --cask rectangle 2>&1 | tee -a "${brew_log}"

# xcode
command_exists xcode-select || xcode-select --install

echo "Finished Setup"




