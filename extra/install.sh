#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dotfile_install $script_dir/abcde.conf $HOME
dotfile_install $script_dir/xprofile $HOME
