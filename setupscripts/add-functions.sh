#!/bin/bash

# setup functions
if [[ -f ./setupscripts/setup-helpers.sh ]]; then
    # shellcheck source=./setupscripts/setup-helpers.sh
    source ./setupscripts/setup-helpers.sh
else
    echo "⛔ Could not find setup-helpers.sh. Exiting..."
    exit 100
fi

if [[ ! -d "${HOME}/scripts/" ]] ; then
    cp -R ./scripts "${HOME}/scripts"
fi

# Let's get some fun color and stuff!
if [[ -f "${HOME}/scripts/prettyfmt.sh" ]]; then
    source "${HOME}/scripts/prettyfmt.sh"
else
    echo "⛔ Could not find ~/scripts/prettyfmt.sh$. Exiting..."
    exit 101
fi

# load the functions
if [[ -f "functions" ]]; then
    source "functions"
else
    colorful_echo "⛔ Could not find ${GREEN}functions${WHITE} in the directory this script was run from. ${YELLOW}Exiting${WHITE}..."
    exit 102
fi
