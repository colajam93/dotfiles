#!/usr/bin/env bash

# scripts
install_path=$HOME/.local/share/dotfiles/scripts
repo_url='https://github.com/colajam93/scripts.git'
install -d "$(dirname -- "$install_path")"
if ! [[ -e $install_path ]]; then
    echo "Clone $repo_url to $install_path"
    git clone "$repo_url" "$install_path"
    cd "$install_path" || exit 1
    bash install.sh
else
    cd "$install_path" || exit 1
    echo "Update $install_path"
    git pull
    bash install.sh
fi
