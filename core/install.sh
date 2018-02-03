#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

install -d $HOME/.config/git
safe_install $script_dir/gitignore_global $HOME/.config/git/ignore
install_all $script_dir gitignore_global
