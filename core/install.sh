#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

install -d "$HOME/.config/git"
dfl_safe_install "$script_dir/gitignore_global" "$HOME/.config/git/ignore"
dfl_install_all "$script_dir" gitignore_global
