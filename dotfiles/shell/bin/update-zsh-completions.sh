#!/usr/bin/env bash
set -euo pipefail

completion_targets=()
declare -A completion_commands=()

register_completion() {
    local target=$1
    shift
    # Store each command as an array, preserving argument boundaries.
    local array_name="completion_command_${#completion_targets[@]}"
    completion_targets+=("$target")
    completion_commands[$target]=$array_name
    declare -ga "$array_name"
    local -n command_args=$array_name
    command_args=("$@")
    if [[ -z ${command_args[0]:-} ]]; then
        printf '%s: no completion generator registered\n' "$target" >&2
        return 2
    fi
}

# Add tools here: target name, then the command that prints a zsh completion.
# Output must start with #compdef and is saved as _<target>.
# This list also supplies --help, argument validation and the default targets.
register_completion kubectl kubectl completion zsh
register_completion k3d     k3d completion zsh
register_completion cargo   rustup completions zsh cargo
register_completion rustup  rustup completions zsh
register_completion mise    mise completion zsh

is_supported_target() {
    local target
    for target in "${completion_targets[@]}"; do
        [[ $target != "$1" ]] || return 0
    done
    return 1
}

update_completion() {
    local target=$1 first_line
    local -n generator="${completion_commands[$target]}"

    if ! command -v "${generator[0]}" > /dev/null 2>&1; then
        printf 'Skipped %s: %s is not on PATH\n' "$target" "${generator[0]}"
        return 0
    fi

    temporary=$(mktemp "$destination/.${target}.XXXXXX") || return 1
    if "${generator[@]}" > "$temporary"; then
        first_line=
        IFS= read -r first_line < "$temporary" || true
        if [[ $first_line == '#compdef '* ]]; then
            if mv -f -- "$temporary" "$destination/_$target"; then
                temporary=
                printf 'Updated %s\n' "$destination/_$target"
                return 0
            fi
        else
            printf '%s: generated output has no #compdef header\n' "$target" >&2
        fi
    fi
    printf '%s: update failed; previous completion kept\n' "$target" >&2
    rm -f -- "$temporary"
    temporary=
    return 1
}

if [[ ${1:-} == --help ]]; then
    printf 'Usage: update-zsh-completions [%s]\n' "${completion_targets[*]}"
    printf 'Generate installed tools\047 completions; then open a new shell.\n'
    exit 0
fi

targets=("$@")
if (( ${#targets[@]} == 0 )); then
    targets=("${completion_targets[@]}")
fi
for target in "${targets[@]}"; do
    if ! is_supported_target "$target"; then
        printf 'Unknown completion target: %s\n' "$target" >&2
        exit 2
    fi
done

data_home=${XDG_DATA_HOME:-$HOME/.local/share}
# XDG paths must be absolute.
[[ $data_home == /* ]] || data_home=$HOME/.local/share
destination=$data_home/zsh/site-functions
umask 077
mkdir -p -- "$destination"
temporary=
trap '[[ -z $temporary ]] || rm -f -- "$temporary"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
status=0

for target in "${targets[@]}"; do
    update_completion "$target" || status=1
done

printf 'Open a new shell to load the updated definitions.\n'
exit "$status"
