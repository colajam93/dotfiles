#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

local_script_dir=$HOME/.local/bin
install -d $local_script_dir
safe_install $script_dir/vboxctl $local_script_dir 755
safe_install $script_dir/testenvctl $local_script_dir 755
