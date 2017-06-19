#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

if [[ $(platform_name) != "linux" ]]; then
    print_error "platform is not Linux"
    exit 1
fi

install_all $script_dir
