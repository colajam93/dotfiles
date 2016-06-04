#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dotfile_install $script_dir/bash_profile $HOME
dotfile_install $script_dir/bashrc $HOME
dotfile_install $script_dir/shell_common.sh $HOME
dotfile_install $script_dir/zshrc $HOME
