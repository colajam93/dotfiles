#!/bin/bash

_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exec_install() {
    sh "${_script_dir}/$1/install.sh"
}

exec_install misc
exec_install shell
exec_install vim
