#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dein_config_dir=$HOME/.vim
source $script_dir/../lib/dotfiles.sh
install -d $dein_config_dir
safe_install $script_dir/plugins.toml $dein_config_dir
safe_install $script_dir/plugins_lazy.toml $dein_config_dir
safe_install $script_dir/vimrc $HOME/.vimrc
