#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

# Evil
evil_install_path=$HOME/.emacs.d/evil
install -d "$(dirname -- "$evil_install_path")"
if ! [[ -e $evil_install_path ]]; then
    dfl_print_information "installing Evil"
    git clone --depth 1 https://github.com/emacs-evil/evil "$evil_install_path"
else
    cd "$evil_install_path" || exit 1
    git pull
fi

# Color scheme
color_scheme_path=$HOME/.emacs.d/iceberg-theme.el

if ! [[ -e $color_scheme_path ]]; then
    curl -L -o "$color_scheme_path" https://raw.githubusercontent.com/apnsngr/iceberg-emacs/master/iceberg-theme.el
fi
