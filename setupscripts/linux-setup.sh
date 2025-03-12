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
draw_sub_title "Linux Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y

command_exists htop || brew install htop 2>&1 | tee -a "${brew_log}"

# dart
if ! command_exists dart; then
    echo "Installing Dart..."
    sudo apt-get update && sudo apt-get install apt-transport-https
    wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | sudo gpg  --dearmor -o /usr/share/keyrings/dart.gpg
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
        | sudo tee /etc/apt/sources.list.d/dart_stable.list
    sudo apt-get update && sudo apt-get install dart
fi

