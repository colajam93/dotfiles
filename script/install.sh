#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

local_script_dir=$HOME/.local/bin
install -d $local_script_dir
foreach_with_generator \
    "safe_install %s $local_script_dir 755" \
    "ls_absolute_path $script_dir/../external/scripts/bin"
