#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

install_path=$HOME/.local/share/dotfiles/latex-templates
repo_url='https://github.com/colajam93/latex-templates.git'
install -d $(dirname $install_path)
if ! [[ -e $install_path ]]; then
    echo "Clone $repo_url to $install_path"
    git clone $repo_url $install_path
    cd $install_path
    bash install.sh
else
    cd $install_path
    echo "Update $install_path"
    git pull
    bash install.sh
fi
