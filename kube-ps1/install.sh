#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

install_path=$HOME/.shell/kube-ps1
mkdir -p "$(dirname -- "$install_path")"
if ! [[ -e $install_path ]]; then
    dfl_print_information "installing kube-ps1"
    git clone https://github.com/jonmosco/kube-ps1.git "$install_path"
else
    cd "$install_path" || exit 1
    git pull
fi
