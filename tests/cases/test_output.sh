#!/usr/bin/env bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export DFL_TEST_LIB="$script_dir/../../dotfiles-lib.sh"

setUp() {
    cd "$SHUNIT_TMPDIR" || return 1
    find . -name . -o -prune -exec rm -rf -- {} +
}

run_tty() {
    local command
    printf -v command '/bin/bash %q' "$PWD/probe.sh"
    timeout 10 script -qefc "$command" /dev/null < /dev/null > terminal-output
}

test_source_succeeds_without_terminal_capabilities() {
    local term output
    for term in unset '' dumb invalid-dotfiles-term; do
        output=$(DFL_TEST_TERM="$term" bash -euo pipefail -c '
            if [[ $DFL_TEST_TERM == unset ]]; then unset TERM; else export TERM="$DFL_TEST_TERM"; fi
            source "$DFL_TEST_LIB"
            dfl_print_information ready
        ')
        assertEquals "$term" 0 "$?"
        assertEquals 'information: ready' "$output"
    done
}

test_source_succeeds_without_tput() {
    local output
    output=$(bash -euo pipefail -c '
        export TERM=xterm PATH=/nonexistent
        source "$DFL_TEST_LIB"
        dfl_print_error ready
    ')
    assertEquals 0 "$?"
    assertEquals 'error: ready' "$output"
}

test_source_succeeds_with_failing_tput() {
    local output
    output=$(bash -euo pipefail -c '
        tput() { printf partial; return 1; }
        source "$DFL_TEST_LIB"
        dfl_print_warning ready
    ')
    assertEquals 0 "$?"
    assertEquals 'warning: ready' "$output"
}

test_terminal_keeps_colors() {
    cat > probe.sh <<'EOF'
set -euo pipefail
export TERM=xterm
source "$DFL_TEST_LIB"
dfl_print_error failure
dfl_print_warning warning
dfl_print_information progress
EOF
    run_tty
    assertEquals 0 "$?"
    local expected
    printf -v expected '%serror:%s failure\n%swarning:%s warning\n%sinformation:%s progress' \
        "$(TERM=xterm tput setaf 1)" "$(TERM=xterm tput sgr0)" \
        "$(TERM=xterm tput setaf 3)" "$(TERM=xterm tput sgr0)" \
        "$(TERM=xterm tput setaf 4)" "$(TERM=xterm tput sgr0)"
    assertEquals "$expected" "$(tr -d '\r' < terminal-output)"
}

test_color_follows_output_destination_after_source() {
    cat > probe.sh <<'EOF'
set -euo pipefail
export TERM=xterm
source "$DFL_TEST_LIB" > source-output
dfl_print_information redirected > plain-output
dfl_print_warning terminal >&2
EOF
    run_tty
    assertEquals 0 "$?"
    assertEquals '' "$(cat source-output)"
    assertEquals 'information: redirected' "$(cat plain-output)"
    assertEquals "$(TERM=xterm tput setaf 3)warning:$(TERM=xterm tput sgr0) terminal" "$(tr -d '\r' < terminal-output)"
}

test_terminal_falls_back_when_tput_fails_or_is_missing() {
    local mode
    for mode in missing color reset; do
        export DFL_TEST_MODE=$mode
        cat > probe.sh <<'EOF'
set -euo pipefail
export TERM=xterm
if [[ $DFL_TEST_MODE == missing ]]; then
    PATH=/nonexistent
else
    tput() {
        if [[ $DFL_TEST_MODE == color || $1 == sgr0 ]]; then
            printf partial
            return 1
        fi
        printf '\033[31m'
    }
fi
source "$DFL_TEST_LIB"
dfl_print_error failure
EOF
        run_tty
        assertEquals "$mode" 0 "$?"
        assertEquals 'error: failure' "$(tr -d '\r' < terminal-output)"
    done
    unset DFL_TEST_MODE
}

test_terminal_falls_back_for_unusable_term() {
    local term
    for term in unset '' dumb invalid-dotfiles-term; do
        export DFL_TEST_TERM=$term
        cat > probe.sh <<'EOF'
set -euo pipefail
if [[ $DFL_TEST_TERM == unset ]]; then unset TERM; else export TERM="$DFL_TEST_TERM"; fi
source "$DFL_TEST_LIB"
dfl_print_information ready
EOF
        run_tty
        assertEquals "$term" 0 "$?"
        assertEquals 'information: ready' "$(tr -d '\r' < terminal-output)"
    done
    unset DFL_TEST_TERM
}

test_quiet_is_silent_on_terminal() {
    cat > probe.sh <<'EOF'
set -euo pipefail
export TERM=xterm
source "$DFL_TEST_LIB"
_dfl_quiet=true
dfl_print_error failure
dfl_print_warning warning
dfl_print_information progress
EOF
    run_tty
    assertEquals 0 "$?"
    assertEquals '' "$(cat terminal-output)"
}

test_quiet_preview_preserves_setting_for_later_output() {
    cat > probe.sh <<'PROBE'
set -euo pipefail
source "$DFL_TEST_LIB"
_dfl_quiet=true
printf config > source
dfl_link_add "$PWD/source" "$PWD/target"
dfl_link_preview > preview-output
[[ $_dfl_quiet == true ]]
dfl_link_apply
dfl_link_apply
dfl_print_error failure
dfl_print_warning warning
dfl_print_information progress
dfl_link_preview > repeated-preview
[[ $_dfl_quiet == true && -L target ]]
PROBE
    bash probe.sh > quiet-output 2>&1
    assertEquals 0 "$?"
    assertEquals '' "$(cat quiet-output)"
    assertEquals "create $PWD/target -> $PWD/source" "$(cat preview-output)"
    assertEquals "skip $PWD/target -> $PWD/source" "$(cat repeated-preview)"
}

test_link_messages_use_terminal_colors() {
    cat > probe.sh <<'EOF'
set -euo pipefail
export TERM=xterm
source "$DFL_TEST_LIB"
printf config > source
dfl_link_add "$PWD/source" "$PWD/target"
dfl_link_apply
dfl_link_apply
rm target
printf existing > target
if dfl_link_preview; then exit 1; fi
EOF
    run_tty
    assertEquals 0 "$?"
    local destination source_path expected
    printf -v destination '%q' "$PWD/target"
    printf -v source_path '%q' "$PWD/source"
    printf -v expected '%screate%s %s -> %s\n%sskip%s %s -> %s\n%sconflict%s %s -> %s (destination already exists)' \
        "$(TERM=xterm tput setaf 2)" "$(TERM=xterm tput sgr0)" "$destination" "$source_path" \
        "$(TERM=xterm tput setaf 4)" "$(TERM=xterm tput sgr0)" "$destination" "$source_path" \
        "$(TERM=xterm tput setaf 1)" "$(TERM=xterm tput sgr0)" "$destination" "$source_path"
    assertEquals "$expected" "$(tr -d '\r' < terminal-output)"
}

# shellcheck source=/dev/null
source "${SHUNIT2:-/usr/share/shunit2/shunit2}"
