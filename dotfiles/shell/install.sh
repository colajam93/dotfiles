#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

shell_dir="$HOME/.shell"
install -d "$shell_dir"
dfl_safe_install "$script_dir/common.sh" "$shell_dir"
platform_specific_script="$script_dir/$(dfl_platform_name).sh"
if [[ -f $platform_specific_script ]]; then
    dfl_safe_install "$platform_specific_script" "$shell_dir/platform.sh"
fi
dfl_install_all "$script_dir" common.sh linux.sh
