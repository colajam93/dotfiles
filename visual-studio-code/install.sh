#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

if [[ $(platform_name) == "linux" ]]; then
    vscode_config_dir="$HOME/.config/Code/User"
elif [[ $(platform_name) == "mac" ]]; then
    vscode_config_dir="$HOME/Library/Application Support/Code/User"
fi

safe_install "$script_dir/keybindings.json" "$vscode_config_dir"
safe_install "$script_dir/locale.json" "$vscode_config_dir"
safe_install "$script_dir/settings.json" "$vscode_config_dir"
