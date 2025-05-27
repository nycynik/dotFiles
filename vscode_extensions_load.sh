#!/bin/bash

# Loop through each extension listed in extensions.txt and install it
while read extension; do
    echo "Installing $extension..."
    code --install-extension "$extension"
done < ./data/code_extensions.txt
