#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

install_path=$HOME/.local/share/oh-my-zsh
mkdir -p $HOME/.local/share
if ! [[ -e $install_path ]]; then
    print_information "installing Oh My Zsh"
    git clone git://github.com/robbyrussell/oh-my-zsh.git $install_path
else
    ZSH=$install_path sh $install_path/tools/upgrade.sh
fi
