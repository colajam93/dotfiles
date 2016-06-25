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
    local list=("core" "develop" "oh-my-zsh" "script" "shell" "vim")
    exec_package "${list[@]}"
}

package_simple() {
    local list=("core" "shell" "vim-simple")
    exec_package "${list[@]}"
}

package_all() {
    local list=("core" "develop" "extra" "i3" "oh-my-zsh" "script" "shell" "vim")
    exec_package "${list[@]}"
}


# main

# parse options
force=false
quiet=false
for OPT in "$@"
do
    case "$OPT" in
        '-f'|'--force' )
            force=true
            shift 1
            ;;
        '-q'|'--quiet' )
            quiet=true
            shift 1
            ;;
        '--'|'-' )
            shift 1
            param+=( "$@" )
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

export _dotfiles_force=$force
export _dotfiles_quiet=$quiet

# default: install default package
if [[ -z ${param} ]]; then
    target='default'
else
    target="${param[0]}"
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

unset _dotfiles_force
unset _dotfiles_quiet
