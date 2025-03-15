#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/add-functions.sh ]] && source ./setupscripts/add-functions.sh || {
    echo "add-functions.sh not found"
    exit 199
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
#   Main
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "WSL Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y

# java
if ! command_exists java || ! command_exists javac; then

    if ! command_exists jenv; then
        echo "jEnv is not installed. Please install it first."
        exit 115
    fi

    JAVA_HOME=$(/usr/libexec/java_home -v 17)
    export JAVA_HOME

    install_brew_package "microsoft-openjdk"

    # After installation add to jEnv
    jenv add /Library/Java/JavaVirtualMachines/microsoft-17.jdk/Contents/Home

    add_post_install_instructions "Java" "Microsoft Java installed, but not set to default. To set it as default use 'jenv global 17'"
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

add_post_install_instructions "SSH Agent" "Add your ssh keys to the keychain by running 'ssh-add -K ~/.ssh/<id>'"

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# end
colorful_echo "   • ${GREEN}Finished WSL/Ubuntu Setup${WHITE}."
