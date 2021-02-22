#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

k9s_dir=$HOME/.k9s
install -d $k9s_dir
safe_install $script_dir/k9s.yml $k9s_dir/config.yml
install_all $script_dir k9s.yml
