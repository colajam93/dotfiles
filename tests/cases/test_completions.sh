#!/usr/bin/env bash

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

setUp() {
    original_path=${original_path:-$PATH}
    fixture=$(mktemp -d "$SHUNIT_TMPDIR/completion.XXXXXX")
    export HOME="$fixture/home"
    export XDG_DATA_HOME="$fixture/data space"
    mkdir -p "$fixture/bin" "$HOME"
    export PATH="$fixture/bin:$original_path"
    updater="$repo_dir/dotfiles/shell/bin/update-zsh-completions.sh"
}

test_generated_completion_is_saved_in_xdg_data() {
    printf '#!/bin/bash\nprintf "#compdef kubectl\\n# generated\\n"\n' > "$fixture/bin/kubectl"
    chmod +x "$fixture/bin/kubectl"
    bash "$updater" kubectl > "$fixture/output" 2>&1
    assertEquals 0 "$?"
    assertTrue "test -s '$XDG_DATA_HOME/zsh/site-functions/_kubectl'"
}

test_failed_generation_preserves_existing_file() {
    mkdir -p "$XDG_DATA_HOME/zsh/site-functions"
    printf 'previous\n' > "$XDG_DATA_HOME/zsh/site-functions/_k3d"
    printf '#!/bin/bash\nprintf "#compdef k3d\\npartial\\n"\nexit 7\n' > "$fixture/bin/k3d"
    chmod +x "$fixture/bin/k3d"
    bash "$updater" k3d > "$fixture/output" 2>&1
    assertNotEquals 0 "$?"
    assertEquals previous "$(cat "$XDG_DATA_HOME/zsh/site-functions/_k3d")"
    assertEquals 1 "$(find "$XDG_DATA_HOME/zsh/site-functions" -type f | wc -l)"
}

test_invalid_output_is_not_installed() {
    printf '#!/bin/bash\nprintf "unexpected output\\n"\n' > "$fixture/bin/mise"
    chmod +x "$fixture/bin/mise"
    bash "$updater" mise > "$fixture/output" 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$XDG_DATA_HOME/zsh/site-functions/_mise'"
}

test_cargo_uses_rustup_generator_and_default_data_home() {
    unset XDG_DATA_HOME
    printf '#!/bin/bash\n[[ "$*" == "completions zsh cargo" ]] || exit 9\nprintf "#compdef cargo\\n# wrapper\\n"\n' > "$fixture/bin/rustup"
    chmod +x "$fixture/bin/rustup"
    bash "$updater" cargo > "$fixture/output" 2>&1
    assertEquals 0 "$?"
    assertTrue "test -s '$HOME/.local/share/zsh/site-functions/_cargo'"
}

test_unknown_target_does_not_change_files() {
    bash "$updater" kubectl unknown > "$fixture/output" 2>&1
    assertEquals 2 "$?"
    assertFalse "test -e '$XDG_DATA_HOME'"
}

test_default_run_updates_all_registered_targets() {
    for tool in kubectl k3d rustup mise; do
        cat > "$fixture/bin/$tool" <<'STUB'
#!/bin/bash
target=${0##*/}
[[ $target == rustup && ${3:-} == cargo ]] && target=cargo
printf '#compdef %s\n# generated\n' "$target"
STUB
        chmod +x "$fixture/bin/$tool"
    done
    bash "$updater" > "$fixture/output" 2>&1
    assertEquals 0 "$?"
    for target in kubectl k3d cargo rustup mise; do
        assertTrue "test -s '$XDG_DATA_HOME/zsh/site-functions/_$target'"
    done
}

. "${SHUNIT2:-/usr/share/shunit2/shunit2}"
