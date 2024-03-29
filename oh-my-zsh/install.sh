#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

install_path=$HOME/.local/share/oh-my-zsh
mkdir -p $HOME/.local/share
if ! [[ -e $install_path ]]; then
    print_information "installing Oh My Zsh"
    git clone https://github.com/ohmyzsh/ohmyzsh.git $install_path
else
    ZSH=$install_path sh $install_path/tools/upgrade.sh
fi
