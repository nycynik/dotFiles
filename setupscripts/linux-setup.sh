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
draw_sub_title "Linux Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y

install_brew_package "htop"

post_install_instructions "SSH Agent" "Add your ssh keys to the keychain by running 'ssh-add -K ~/.ssh/<id>'"


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# all done
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
colorful_echo "   • ${GREEN}Finished Linux Setup${WHITE}."

