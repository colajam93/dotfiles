#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dotfile_install $script_dir/gdbinit $HOME
dotfile_install $script_dir/tmux.conf $HOME

if ! [[ $1 = 'simple' ]]; then
    dotfile_install $script_dir/abcde.conf $HOME
    dotfile_install $script_dir/clang-format $HOME
    dotfile_install $script_dir/gitconfig $HOME
    dotfile_install $script_dir/xprofile $HOME
fi
