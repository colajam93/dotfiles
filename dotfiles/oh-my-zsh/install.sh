#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

install_path=$HOME/.local/share/oh-my-zsh
mkdir -p "$HOME/.local/share"
if ! [[ -e $install_path ]]; then
    dfl_print_information "installing Oh My Zsh"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$install_path"
fi
