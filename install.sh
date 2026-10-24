#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || exit 1
source "$DOTFILES_ROOT/vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

force=false
quiet=false
dry_run=false
param=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force) force=true ;;
        -q|--quiet) quiet=true ;;
        --dry-run) dry_run=true ;;
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

# Validate every category before sourcing declarations or running installers.
for target in "${targets[@]}"; do
    if [[ ! $target =~ ^[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)*$ ]] ||
       [[ ! -f $DOTFILES_ROOT/dotfiles/$target/links.sh && ! -f $DOTFILES_ROOT/dotfiles/$target/install.sh ]]; then
        printf 'Unknown category: %s\n' "$target" >&2
        exit 1
    fi
done

dfl_link_reset
for target in "${targets[@]}"; do
    if [[ -f $DOTFILES_ROOT/dotfiles/$target/links.sh ]]; then
        # Categories register their links in this shell; they do not apply them.
        source "$DOTFILES_ROOT/dotfiles/$target/links.sh"
    fi
done

if [[ $dry_run == true ]]; then
    dfl_link_preview || exit 1
    for target in "${targets[@]}"; do
        if [[ -f $DOTFILES_ROOT/dotfiles/$target/install.sh ]]; then
            printf 'legacy %q (not executed; preview unavailable)\n' "$DOTFILES_ROOT/dotfiles/$target/install.sh"
        fi
    done
    exit 0
fi

dfl_link_apply || exit 1
for target in "${targets[@]}"; do
    if [[ -f $DOTFILES_ROOT/dotfiles/$target/install.sh ]]; then
        bash "$DOTFILES_ROOT/dotfiles/$target/install.sh" || exit 1
    fi
done
