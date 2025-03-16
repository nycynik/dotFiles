#!/bin/bash

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Functions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
[[ -f ./setupscripts/add-functions.sh ]] && source ./setupscripts/add-functions.sh || {
    echo "add-functions.sh not found"
    exit 199
}
BOX_WIDTH=80
export BOX_WIDTH

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
#   MAiN
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "Linux Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y
sudo apt-get install gnupg2 -y

install_brew_package "htop"

add_post_install_instructions "SSH Agent" "Add your ssh keys to the keychain by running 'ssh-add -K ~/.ssh/<id>'"


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# all done
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
colorful_echo "   • ${GREEN}Finished Linux Setup${WHITE}."
