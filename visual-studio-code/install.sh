#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

if [[ $(platform_name) == "linux" ]]; then
    vscode_config_dir="$HOME/Library/Application Support/Code/User"
elif [[ $(platform_name) == "mac" ]]; then
    vscode_config_dir="$HOME/.config/Code/User"
fi

install_all "$vscode_config_dir"