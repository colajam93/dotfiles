#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

# Vim
dein_config_dir=$HOME/.vim
install -d $dein_config_dir
safe_install $script_dir/plugins.toml $dein_config_dir
safe_install $script_dir/plugins_lazy.toml $dein_config_dir
install_all $script_dir plugins.toml plugins_lazy.toml

# Neovim
nvim_config_dir=$HOME/.config/nvim
install -d $nvim_config_dir
safe_install $script_dir/vimrc $nvim_config_dir/init.vim
safe_install $script_dir/plugins.toml $nvim_config_dir
safe_install $script_dir/plugins_lazy.toml $nvim_config_dir
