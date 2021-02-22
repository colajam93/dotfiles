#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/external/libshellscript/libshellscript/libshellscript.sh

exec_package() {
    local e
    for e in "${@}"; do
        bash "${script_dir}/$e/install.sh"
    done
}

# main

# parse options
force="false"
quiet="false"
for OPT in "$@"
do
    case "$OPT" in
        '-f'|'--force' )
            force="true"
            shift 1
            ;;
        '-q'|'--quiet' )
            quiet="true"
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

if [[ -z ${param} ]] || [[ ${param[0]} == "default" ]]; then
    targets=("core" "develop" "oh-my-zsh" "script" "shell" "vim")
elif [[ ${param[0]} == "simple" ]]; then
    targets=("core" "shell" "vim-simple")
elif [[ ${param[0]} == "all" ]] && [[ $(platform_name) == "linux" ]]; then
    targets=("core" "develop" "oh-my-zsh" "script" "shell" "vim" "emacs")
elif [[ ${param[0]} == "all" ]] && [[ $(platform_name) == "mac" ]]; then
    targets=("core" "develop" "oh-my-zsh" "script" "shell" "vim" "emacs")
else
    targets=("${param[@]}")
fi

# set global options
export _dotfiles_force=$force
export _dotfiles_quiet=$quiet

exec_package "${targets[@]}"

# unset global options
unset _dotfiles_force
unset _dotfiles_quiet
