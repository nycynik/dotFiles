#!/bin/bash

mkdir -p 'data'
echo "Saving VSCode Extensions into ./data/code_extensions.txt"
code --list-extensions > ./data/code_extensions.txt
