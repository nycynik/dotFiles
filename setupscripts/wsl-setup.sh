#!/bin/bash

# Let's get some fun color and stuff!
if [[ -f "${HOME}"/scripts/prettyfmt.sh ]]; then
    source "${HOME}"/scripts/prettyfmt.sh
else
    echo "⛔ Could not find ~/scripts/prettyfmt.sh. Exiting..."
    exit 1
fi

# get the functions
if [[ -f "${HOME}"/.dotfiles/functions ]]; then
    source "${HOME}"/.dotfiles/functions
else
    echo "⛔ Could not find ~/.dotfiles/functions. Exiting..."
    exit 1
fi

draw_a_line "LINE"
draw_sub_title "WSL Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y

# java
if ! command_exists java || ! command_exists javac; then
    echo "Installing OpenJDK..."
    brew install --cask microsoft-openjdk 2>&1 | tee -a "${brew_log:?}"
    # After installation, you might need to link it
    sudo ln -sfn "$(brew --prefix)"/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

    JAVA_HOME=$(/usr/libexec/java_home -v 17)
    export JAVA_HOME

    jenv add /Library/Java/JavaVirtualMachines/microsoft-17.jdk/Contents/Home
    jenv global 17
fi

# dart
# if ! command_exists dart; then
#     echo "Installing Dart..."
#     sudo apt-get update && sudo apt-get install apt-transport-https
#     wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
#         | sudo gpg  --dearmor -o /usr/share/keyrings/dart.gpg
#     echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
#         | sudo tee /etc/apt/sources.list.d/dart_stable.list
#     sudo apt-get update && sudo apt-get install dart
# fi
