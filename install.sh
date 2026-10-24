#!/usr/bin/env bash

DOTFILES_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || exit 1
source "$DOTFILES_ROOT/vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

force=false
quiet=false
param=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force) force=true ;;
        -q|--quiet) quiet=true ;;
        --|-) shift; param+=("$@"); break ;;
        -*) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
        *) param+=("$1") ;;
    esac
    shift
done

case ${param[0]:-default} in
    default|all) targets=(core develop oh-my-zsh script shell vim) ;;
    simple) targets=(core shell vim-simple) ;;
    *) targets=("${param[@]}") ;;
esac

export _dfl_force=$force _dfl_quiet=$quiet

for target in "${targets[@]}"; do
    bash "$DOTFILES_ROOT/dotfiles/$target/install.sh" || exit 1
done
