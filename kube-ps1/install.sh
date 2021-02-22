#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

install_path=$HOME/.shell/kube-ps1
mkdir -p $(dirname $install_path)
if ! [[ -e $install_path ]]; then
    print_information "installing kube-ps1"
    git clone https://github.com/jonmosco/kube-ps1.git $install_path
else
    cd $install_path
    git pull
fi
