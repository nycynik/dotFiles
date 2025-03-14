#!/bin/bash

# This is the various helper functions that are used to make this easier to understand and maintain
# These are only needed during installation, so we can safely remove them after the installation is complete
# Also, they don't get added to the functions file since we only want them during installation.

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Add config to Shell
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Add config to multiple shells. Hard coded now to zshrc and bash_profile, but you can add more 
# if/when we get to the next shell. I always like to maintain bash, even though I primarly
# use zsh, becuase So many script files are /bin/bash. 
# This just makes my life more reasonable.
#
# Usage:
#   add_config_to_shells "Marker" <<'EOF'
#   # Your config here
#   EOF
add_config_to_shells() {
    local marker="# Added by Dotfiles - DO NOT REMOVE THIS LINE - ${1}"
    local config_files=("$HOME/.zshrc" "$HOME/.bash_profile")

    # Capture the content from stdin
    local config_content
    config_content=$(cat)

    # Prepare config content with ${HOME} expanded
    eval "temp_content=\"$config_content\""

    for config_file in "${config_files[@]}"; do
        if ! grep -q "$marker" "$config_file"; then
            {
                echo -e "\n$marker"
                cat <<EOF
$temp_content
EOF
            } >> "$config_file"
            echo -e "$marker-END\n" >> "$config_file" # keep it neat.

            colorful_echo "   • ${BLUE}Added config to ${GREEN}${config_file}${WHITE}."
        else
            colorful_echo "   • ${YELLOW}Marker already exists in ${config_file}${WHITE}."
        fi
    done
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Brew helper functions for installation
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# This set of functions simplifies the installation of brew packages. It handles both --cask and
# regular brew packages. If the package is already installed, it's skipped and a note of that is shown 
# to the user. Otherwise it installs the package and logs it to the brew_log file.
# 
# Usage:
#   install_brew_package "package_name"
brew_log="${brew_log:-"${HOME}/.dotfiles/logs/brew_log_$(date +%Y%m%d).log"}"
[[ -d "${HOME}/.dotfiles/logs" ]] || mkdir -p "${HOME}/.dotfiles/logs"
touch "${brew_log}"
brew_exists() {
  brew ls --versions "$1" &> /dev/null || brew ls --versions "$1" --cask &> /dev/null
}
install_brew_package() {
    local package_name="$1"

    # Die if brew is not installed.
    if ! command -v brew &> /dev/null; then
        echo "⛔ Could not find brew. Exiting..."
        exit 110
    fi

    # Check if the package exists as a cask or formula and install accordingly
    if ! brew list --formula "$package_name" &> /dev/null; then
        if brew search --cask --quiet "^${package_name}$" &> /dev/null; then
            if ! brew list --cask "$package_name" &> /dev/null; then
                brew install --cask "$package_name" 2>&1 | tee -a "${brew_log}"
            else
                colorful_echo "   • ${YELLOW}$package_name (cask) already installed, skipping${WHITE}."
            fi
        elif brew search --formula --quiet "^${package_name}$" &> /dev/null; then
            brew install "$package_name" 2>&1 | tee -a "${brew_log}"
        else
            colorful_echo "   • ${RED}$package_name not found as a formula or cask${WHITE}."
        fi
    else
        colorful_echo "   • ${YELLOW}$package_name (formula) already installed, skipping${WHITE}."
    fi
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Instsall zsh plugin
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# this function installs a zsh plugin if it's not already installed. It also adds the plugin to the
# plugins list in the .zshrc file.
#
# Usage:
#   install_zsh_plugin "repo_url" 
install_zsh_plugin() {
    local repo_url="$1"
    local plugin_name
    plugin_name=$(basename "$repo_url" .git)  # Extracts repo name from URL
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    local zshrc="$HOME/.zshrc"

    # Clone the plugin if it's missing
    if [[ ! -d "$plugin_dir" ]]; then
        colorful_echo "   • ${BLUE}Installing $plugin_name${WHITE}."
        git clone --depth 1 "$repo_url" "$plugin_dir"
    else
        colorful_echo "   • ${YELLOW}$plugin_name already installed, skipping${WHITE}."
    fi

    # Enable the plugin in .zshrc if not already enabled
    if ! grep -qE "plugins=.*\b$plugin_name\b" "$zshrc"; then
        sed -i '' -E "s/(^plugins=\([^)]*)\)/\1 $plugin_name)/" "$zshrc"
        colorful_echo "   • ${GREEN}Added ${plugin_name} to plugins in .zshrc${WHITE}."
    fi
}

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Post installation instructions
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# This set of functions manage a set of instructions that are built during the installation. Then
# it's output at the end.
#
#setup the output location for the post installation tasks
post_install_tasks="${HOME}/.dotfiles/logs/post_install_tasks_$(date +%Y%m%d).log"
# Create the post install tasks file if it doesn't exist
if [[ -f "${post_install_tasks}" ]] ; then
	mv "${post_install_tasks}" "${post_install_tasks}.$(date +%Y%m%d)"
fi
touch "${post_install_tasks}"
# create storage for the instructions with groups key is group, value is instruction
declare -A post_install_instructions
# function to add a group of instructions. If the group exists, the instructions are
# added to the list of instructions for that group.
# Usage:
#   add_post_install_instructions "Group Name" <<'EOF'
#   # Your instructions here
#   EOF
add_post_install_instructions() {
    local group_name="$1"
    local instructions
    instructions=$(cat)

    if [[ -z "${post_install_instructions[$group_name]}" ]]; then
        post_install_instructions[$group_name]="$instructions"
    else
        post_install_instructions[$group_name]="${post_install_instructions[$group_name]}\n$instructions"
    fi
}
# function that writes out the instructions to the file that is used to show 
# them, and is the record for later. It writes out the instructions, the groups show in alphabetical order
# and instructions show in the order they were added.
write_post_install_instructions() {
    # Sort the groups alphabetically
    for group in "${!post_install_instructions[@]}"; do
        echo -e "## ${group}" >> "$post_install_tasks"
        # instructions are shown in the order they were added.
        # they are not sorted.
        echo -e "${post_install_instructions[$group]}" >> "$post_install_tasks"
    done
}
# function is called after the installation is complete. It prints a message to the user
# with instructions on how to restart their shell or source their .zshrc file.
#
# Usage:
#   post_installation_instructions
show_post_install_tasks() {
    colorful_echo "\n${GREEN}Post-Installation Tasks${WHITE}:"
    while IFS= read -r line; do
        if [[ $line == \#\#* ]]; then
            # It's a section header
            echo -e "\n${BLUE}${line#\#\# }:${WHITE}"
        else
            # It's a regular item
            echo -e "${YELLOW}  • ${WHITE}$line"
        fi
    done < "$post_install_tasks"
}
