#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

shell_dir="$HOME/.shell"
install -d $shell_dir
safe_install $script_dir/common.sh $shell_dir
platform_specific_script="$script_dir/$(platform_name).sh"
if [[ -f $platform_specific_script ]]; then
    safe_install $platform_specific_script $shell_dir/platform.sh
fi
install_all $script_dir common.sh linux.sh
