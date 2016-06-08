#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dotfile_install $script_dir/clang-format $HOME
dotfile_install $script_dir/gdbinit $HOME
dotfile_install $script_dir/ideavimrc $HOME
