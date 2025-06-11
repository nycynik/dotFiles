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
# keychain for ssh agent
sudo apt install keychain -y

colorful_echo "   • ${GREEN}Adding ssh keys to keychain${WHITE}."

eval `keychain --eval --agents ssh github`
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/github_key

replace_config_in_file "SSH-GITHUB" "${HOME}/.ssh/config" << 'EOF'
Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  IdentityFile ~/.ssh/github_key
  IdentitiesOnly yes
  ForwardX11 no
EOF


replace_config_in_shells "SSHKEYS" <<'EOF'
# Start SSH Agent if not running (ubuntu server)
eval `keychain --eval --agents ssh github_key`
EOF

add_post_install_instructions "SSH" "Add your ssh keys to the keychain by running 'keychain --eval --agents ssh <id>' for any additional keys"


# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
#   MAiN
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
draw_a_line "LINE"
draw_sub_title "Linux Setup"
draw_a_line "LINE"

sudo apt update && sudo apt upgrade -y
sudo apt-get install gnupg2 -y

install_brew_package "htop"
install_brew_package "docker"

add_post_install_instructions "SSH Agent" "Add your ssh keys to the keychain by running 'ssh-add -K ~/.ssh/<id>'"

cat <<EOT >> ~/.bashrc
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOT

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# all done
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
colorful_echo "   • ${GREEN}Finished Linux Setup${WHITE}."
