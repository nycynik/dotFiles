#!/bin/bash

# This is the various helper functions that are used to make this easier to understand and maintain
# These are only needed during installation, so we can safely remove them after the installation is complete
# Also, they don't get added to the functions file since we only want them during installation.

# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# Add config to Files, including the shell files as a special case.
# --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
# functions to manage config blocks. adds and remoes them. also updates them.
marker_string="# Added by Dotfiles - DO NOT REMOVE THIS LINE - "

# add a config block with makers to a file. The format is shell and happens to work with python, or
# anything else that uses # as a comment marker.
add_config_to_file() {
    local name="$1"         # Marker name to identify the config block
    local file="$2"         # Target file where the config is to be added
    local config_content="$3" # Content to add to the file
    local marker="# Added by Dotfiles - DO NOT REMOVE THIS LINE - ${name}"

    if ! grep -q "$marker" "$file"; then
        # no marker so add content surrounded by markers
        {
            echo -e "\n$marker"
            cat <<EOF
$config_content
EOF
            echo -e "$marker-END\n"
        } >> "$file"
        colorful_echo "   • ${BLUE}Added config to ${GREEN}${file}${WHITE}."
    else
        colorful_echo "   • ${YELLOW}Skipping update for ${file}${WHITE}."
    fi
}
# Replaces a config block, using above functions
#
# Usage:
#   replace_config_in_file "Marker" <<'EOF'
#   # Your config here
#   EOF
replace_config_in_file() {
    local name="$1"  # Marker name to identify the config block
    local file="$2"  # Target file where the config is to be updated
    local config_content
    config_content=$(cat)  # Capture the content from stdin

    remove_config_from_file "$name" "$file" "quiet"
    add_config_to_file "$name" "$file" "$config_content"
}

# This function removes content between the markers.
remove_config_from_file() {
    local name="$1"  # Marker name to identify the config block
    local file="$2"  # Target file from which the config is to be removed
    local quiet="$3"    # Optional flag to suppress error message
    local marker="${marker_string}${name}"

    if grep -q "$marker" "$file"; then
        # Use sed to remove everything between markers
        sed -i '' "/$marker/,/$marker-END/d" "$file"
    else
        if [ "$quiet" != "quiet" ]; then
            colorful_echo "   • ${YELLOW}No marker found in ${file}${WHITE}."
        fi
    fi
}

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
    local name="$1"
    local config_content
    config_content=$(cat)  # Capture the content from stdin

    # Define the config files you want to add config to
    local config_files=("$HOME/.zshrc" "$HOME/.bash_profile")

    for config_file in "${config_files[@]}"; do
        add_config_to_file "$name" "$config_file" "$config_content"
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
brew_get_brew_log_path() {
    echo "${brew_log}"
}
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
        if brew search --cask --quiet "/^${package_name}$/" &> /dev/null; then
            if ! brew list --cask "$package_name" &> /dev/null; then
                brew install --cask "$package_name" 2>&1 | tee -a "${brew_log}"
            else
                colorful_echo "   • ${YELLOW}$package_name (cask) already installed, skipping${WHITE}."
            fi
        elif brew search --formula --quiet "/^${package_name}$/" &> /dev/null; then
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
temp_storage="${post_install_tasks}.tmp"

# This function makes a new file to store all the post install tasks.
init_post_install_tasks() {
    [[ -d "${HOME}/.dotfiles/logs" ]] || mkdir -p "${HOME}/.dotfiles/logs"
    # Create the post install tasks file if it doesn't exist
    if [[ -f "${post_install_tasks}" ]] ; then
        rm "${post_install_tasks}"
    fi
    touch "${post_install_tasks}"

    # new temp file each time
    if [[ -f "${temp_storage}" ]] ; then
        rm "${temp_storage}"
    fi
    touch "${temp_storage}"
}

# function to add a group of instructions. If the group exists, the instructions are
# added to the list of instructions for that group.
# Usage:
#   add_post_install_instructions "Group Name" "Information"
add_post_install_instructions() {
    local group_name="$1"
    local instructions="$2"

    # Append the instruction to the temp file, marking the group
    echo -e "$group_name|$instructions" >> "$temp_storage"
}

# function that writes out the instructions to the file that is used to show
# them, and is the record for later. It writes out the instructions, the groups show in alphabetical order
# and instructions show in the order they were added.
write_post_install_instructions() {
    sorted_file="${post_install_tasks}.sorted"

    # First, extract all unique group names and sort them
    sorted_groups=$(cut -d'|' -f1 "$temp_storage" | sort -u)

    # Clear the output file before writing
    [[ -f "$sorted_file" ]] && rm "$sorted_file"
    touch "$sorted_file"

    # Iterate over sorted group names and append their instructions
    while IFS= read -r group; do
        echo "## $group" >> "$sorted_file"
        grep "^$group|" "$temp_storage" | cut -d'|' -f2- | while IFS= read -r instruction; do
            echo "  • $instruction" >> "$sorted_file"
        done
        echo "" >> "$sorted_file"  # Blank line for spacing
    done <<< "$sorted_groups"

    # Move sorted content to final file
    mv "$sorted_file" "$post_install_tasks"
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
            echo -e "\n${BLUE}${line#\#\# }${WHITE}:"
        elif [[ -n "$line" ]]; then
            # It's a regular item
            echo -e "${YELLOW}$line${WHITE}"
        fi
    done < "$post_install_tasks"
}
