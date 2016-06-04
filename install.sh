#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exec_script() {
    bash "${script_dir}/$1/install.sh"
}

exec_package() {
    local e
    for e in "${@}"; do
        exec_script "$e"
    done
}

package_default() {
    local list=("core" "develop" "oh-my-zsh" "shell" "vim")
    exec_package "${list[@]}"
}

package_simple() {
    local list=("core" "shell" "vim-simple")
    exec_package "${list[@]}"
}

package_all() {
    local list=("core" "develop" "extra" "i3" "oh-my-zsh" "shell" "vim")
    exec_package "${list[@]}"
}


# main

# default: install default package
if [[ "$#" == 0 ]]; then
    target='default'
else
    target="$1"
fi

if [[ "${target}" == 'default' ]]; then
    package_default
elif [[ "${target}" == 'simple' ]]; then
    package_simple
elif [[ "${target}" == 'all' ]]; then
    package_all
else
    exec_package "${target}"
fi
