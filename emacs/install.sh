#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

# Proof General
pg_install_path=$HOME/.emacs.d/lisp/PG
install -d $(dirname $pg_install_path)
if ! [[ -e $pg_install_path ]]; then
    print_information "installing Proof General"
    git clone --depth 1 https://github.com/ProofGeneral/PG $pg_install_path
    cd $pg_install_path
    make
else
    cd $pg_install_path
    git pull
    make
fi

# Evil
evil_install_path=$HOME/.emacs.d/evil
install -d $(dirname $evil_install_path)
if ! [[ -e $evil_install_path ]]; then
    print_information "installing Evil"
    git clone --depth 1 https://github.com/emacs-evil/evil $evil_install_path
else
    cd $evil_install_path
    git pull
fi

emacs_config_dir=$HOME/.emacs.d
install -d $emacs_config_dir
safe_install $script_dir/init.el $emacs_config_dir
