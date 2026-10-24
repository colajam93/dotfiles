#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

dfl_install_all "$script_dir"
