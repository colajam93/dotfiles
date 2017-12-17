#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

install_path=$HOME/.local/share/scripts
if ! [[ -e $install_path ]]; then
    echo "Clone https://github.com/colajam93/scripts.git to $install_path"
    git clone https://github.com/colajam93/scripts.git $install_path
    cd $install_path
    bash install.sh
else
    cd $install_path
    echo "Update $install_path"
    git pull
    bash install.sh
fi
