#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dotfile_install $script_dir/bash_profile $HOME
dotfile_install $script_dir/bashrc $HOME
dotfile_install $script_dir/shell_common.sh $HOME

if ! [[ $1 = 'simple' ]]; then
    dotfile_install $script_dir/zshrc $HOME
    if ! [[ -e $HOME/.oh-my-zsh ]]; then
        print_information "installing Oh My Zsh"
        git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    fi
fi
