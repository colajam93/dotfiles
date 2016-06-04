#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

dein_config_dir=$HOME/.vim
install -d $dein_config_dir
safe_install $script_dir/plugins.toml $dein_config_dir
safe_install $script_dir/plugins_lazy.toml $dein_config_dir
dotfile_install $script_dir/vimrc $HOME
dotfile_install $script_dir/gvimrc $HOME
