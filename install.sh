#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exec_install() {
    dir=$1
    shift
    sh "${script_dir}/${dir}/install.sh" $@
}

exec_install misc $@
exec_install shell $@
exec_install vim $@
