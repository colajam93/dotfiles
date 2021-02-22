#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

install_path=$HOME/.asdf
mkdir -p $(dirname $install_path)
if ! [[ -e $install_path ]]; then
    print_information "installing asdf"
    git clone https://github.com/asdf-vm/asdf.git $install_path --branch v0.8.0 
fi
