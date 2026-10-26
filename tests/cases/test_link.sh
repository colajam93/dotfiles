#!/usr/bin/env bash

setUp() {
    cd "$SHUNIT_TMPDIR" || return 1
    find . -name . -o -prune -exec rm -rf -- {} +
    printf 'config\n' > source
    dfl_link_reset
}

test_link_registration_and_check_do_not_create_files() {
    dfl_link_add source target/config
    assertEquals 0 "$?"
    dfl_link_check
    assertEquals 0 "$?"
    assertFalse '[[ -e target ]]'
}

test_link_apply_creates_parents_and_is_repeatable() {
    dfl_link_add source target/config
    dfl_link_apply
    assertEquals 0 "$?"
    assertTrue '[[ -L target/config ]]'
    assertEquals "$(realpath source)" "$(readlink target/config)"
    local inode
    inode=$(stat -c %i target/config)
    dfl_link_apply
    assertEquals 0 "$?"
    assertEquals "$inode" "$(stat -c %i target/config)"
}

test_link_keeps_equivalent_relative_link() {
    mkdir target
    ln -s ../source target/config
    dfl_link_add source target/config
    dfl_link_apply
    assertEquals 0 "$?"
    assertEquals ../source "$(readlink target/config)"
}

test_link_to_different_hardlink_is_a_conflict() {
    ln source other
    ln -s other existing
    dfl_link_add source target/new
    dfl_link_add source existing
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
    assertEquals other "$(readlink existing)"
}

test_link_conflicts_prevent_all_changes() {
    local kind
    for kind in file directory link dangling; do
        dfl_link_reset
        rm -rf target
        mkdir target
        case $kind in
            file) printf 'old\n' > target/conflict ;;
            directory) mkdir target/conflict ;;
            link) printf 'other\n' > other; ln -s ../other target/conflict ;;
            dangling) ln -s missing target/conflict ;;
        esac
        local before
        before=$(stat -c '%i:%F' target/conflict)
        dfl_link_add source target/new
        dfl_link_add source target/conflict
        dfl_link_apply > /dev/null 2>&1
        assertNotEquals "$kind must fail" 0 "$?"
        assertFalse '[[ -e target/new || -L target/new ]]'
        assertEquals "$before" "$(stat -c '%i:%F' target/conflict)"
    done
}

test_link_missing_source_prevents_all_changes() {
    dfl_link_add source target/first
    dfl_link_add missing target/second
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
}

test_link_duplicate_destination_is_rejected() {
    mkdir target
    ln -s target alias
    dfl_link_add source target/config
    dfl_link_add source alias/config
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target/config ]]'
}

test_link_overlapping_destinations_are_rejected() {
    mkdir source-dir
    dfl_link_add source-dir target
    dfl_link_add source target/config
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
    assertFalse '[[ -e source-dir/config ]]'
}

test_link_existing_directory_link_overlap_is_rejected() {
    mkdir source-dir
    ln -s source-dir target
    ln -s source-dir alias
    local order
    for order in parent-first child-first; do
        dfl_link_reset
        if [[ $order == parent-first ]]; then
            dfl_link_add source-dir target
            dfl_link_add source alias/config
        else
            dfl_link_add source alias/config
            dfl_link_add source-dir target
        fi
        dfl_link_check > /dev/null 2>&1
        assertNotEquals "$order must reject overlapping destinations" 0 "$?"
        assertFalse '[[ -e source-dir/config ]]'
    done
}

test_link_parent_file_is_rejected_before_changes() {
    printf 'old\n' > parent
    dfl_link_add source target/config
    dfl_link_add source parent/config
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
    assertEquals old "$(cat parent)"
}

test_link_existing_parent_symlink() {
    mkdir actual
    ln -s actual alias
    dfl_link_add source alias/nested/config
    dfl_link_apply
    assertEquals 0 "$?"
    assertEquals actual "$(readlink alias)"
    assertTrue '[[ -L actual/nested/config ]]'
    assertEquals config "$(cat actual/nested/config)"
}

test_link_dangling_parent_is_rejected_before_changes() {
    ln -s missing parent
    dfl_link_add source target/config
    dfl_link_add source parent/config
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target || -e missing ]]'
    assertEquals missing "$(readlink parent)"
}

test_link_broken_source_is_rejected() {
    ln -s missing broken
    dfl_link_add broken target/config
    dfl_link_check > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
}

test_link_apply_returns_io_failure() {
    mkdir target
    chmod 555 target
    dfl_link_add source target/config
    dfl_link_apply > /dev/null 2>&1
    local code=$?
    chmod 755 target
    assertNotEquals 0 "$code"
    assertFalse '[[ -e target/config || -L target/config ]]'
}

test_link_paths_are_bound_at_registration() {
    local name=$'config [*]\n'
    cp source "$name"
    dfl_link_add "$name" "target/$name"
    mkdir elsewhere
    cd elsewhere || return 1
    dfl_link_apply
    assertEquals 0 "$?"
    if [[ ! -L ../target/$name ]]; then
        fail "Expected a symlink at the registered destination"
    fi
    assertEquals config "$(cat "../target/$name")"
}

test_link_apply_rechecks_after_check() {
    dfl_link_add source target/config
    dfl_link_check
    assertEquals 0 "$?"
    mkdir target
    printf 'old\n' > target/config
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertEquals old "$(cat target/config)"
}

test_link_reset_and_empty_plan() {
    dfl_link_add source target/config
    dfl_link_reset
    dfl_link_apply
    assertEquals 0 "$?"
    assertFalse '[[ -e target ]]'
}

test_link_invalid_arguments() {
    dfl_link_add source > /dev/null 2>&1
    assertNotEquals 0 "$?"
    dfl_link_add '' target > /dev/null 2>&1
    assertNotEquals 0 "$?"
    dfl_link_add source '' > /dev/null 2>&1
    assertNotEquals 0 "$?"
}

test_link_apply_multiple_registrations() {
    printf 'second\n' > other
    dfl_link_add source target/core/config
    dfl_link_add other target/shell/config
    dfl_link_apply
    assertEquals 0 "$?"
    assertTrue '[[ -L target/core/config && -L target/shell/config ]]'
    assertEquals config "$(cat target/core/config)"
    assertEquals second "$(cat target/shell/config)"
}

test_link_apply_stops_without_rolling_back() {
    mkdir blocked
    chmod 555 blocked
    dfl_link_add source target/first
    dfl_link_add source blocked/second
    dfl_link_add source target/third
    dfl_link_apply > /dev/null 2>&1
    local code=$?
    chmod 755 blocked
    assertNotEquals 0 "$code"
    assertTrue '[[ -L target/first ]]'
    assertEquals config "$(cat target/first)"
    assertFalse '[[ -e blocked/second || -L blocked/second ]]'
    assertFalse '[[ -e target/third || -L target/third ]]'
}

test_link_apply_returns_parent_creation_failure() {
    mkdir blocked
    chmod 555 blocked
    dfl_link_add source blocked/nested/config
    dfl_link_apply > /dev/null 2>&1
    local code=$?
    chmod 755 blocked
    assertNotEquals 0 "$code"
    assertFalse '[[ -e blocked/nested ]]'
}

test_link_apply_rechecks_deleted_source() {
    cp source other
    dfl_link_add source target/first
    dfl_link_add other target/second
    dfl_link_check
    assertEquals 0 "$?"
    rm other
    dfl_link_apply > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e target ]]'
}

test_link_preview_shows_create_and_skip_without_changes() {
    mkdir target
    ln -s ../source target/existing
    local inode output
    inode=$(stat -c %i target/existing)
    dfl_link_add source target/nested/new
    dfl_link_add source target/existing
    dfl_link_preview > preview-output
    assertEquals 0 "$?"
    output=$(cat preview-output)
    assertEquals "create $PWD/target/nested/new -> $PWD/source
skip $PWD/target/existing -> $PWD/source" "$output"
    assertFalse '[[ -e target/nested ]]'
    assertEquals "$inode" "$(stat -c %i target/existing)"
    assertEquals ../source "$(readlink target/existing)"
    dfl_link_apply
    assertEquals 0 "$?"
    assertTrue '[[ -L target/nested/new ]]'
}

test_link_preview_reports_conflict_without_changes() {
    printf 'old\n' > conflict
    dfl_link_add source target/new
    dfl_link_add source conflict
    local output code
    output=$(dfl_link_preview 2> /dev/null)
    code=$?
    assertNotEquals 0 "$code"
    assertEquals "create $PWD/target/new -> $PWD/source
conflict $PWD/conflict -> $PWD/source (destination already exists)" "$output"
    assertFalse '[[ -e target ]]'
    assertEquals old "$(cat conflict)"
}

test_link_preview_escapes_special_paths() {
    local name=$'config [*]\n' expected output
    cp source "$name"
    dfl_link_add "$name" "target/$name"
    printf -v expected 'create %q -> %q' "$PWD/target/$name" "$PWD/$name"
    output=$(dfl_link_preview)
    assertEquals 0 "$?"
    assertEquals "$expected" "$output"
    assertEquals 1 "$(printf '%s\n' "$output" | wc -l)"
    assertFalse '[[ -e target ]]'
}

test_link_preview_empty_plan() {
    local output
    output=$(dfl_link_preview)
    assertEquals 0 "$?"
    assertEquals '' "$output"
}

test_link_apply_logs_create_and_skip() {
    mkdir target
    ln -s ../source target/existing
    dfl_link_add source target/new
    dfl_link_add source target/existing
    local output
    output=$(dfl_link_apply)
    assertEquals 0 "$?"
    assertEquals "create $PWD/target/new -> $PWD/source
skip $PWD/target/existing -> $PWD/source" "$output"
    assertTrue '[[ -L target/new ]]'
    assertEquals ../source "$(readlink target/existing)"
}

test_link_apply_quiet_suppresses_create_and_skip() {
    dfl_link_add source target/new
    local output
    output=$(_dfl_quiet=true dfl_link_apply)
    assertEquals 0 "$?"
    assertEquals '' "$output"
    assertTrue '[[ -L target/new ]]'
    output=$(_dfl_quiet=true dfl_link_apply)
    assertEquals 0 "$?"
    assertEquals '' "$output"
}

test_link_apply_logs_escaped_paths() {
    local name=$'config [*]\n' expected output
    cp source "$name"
    dfl_link_add "$name" "target/$name"
    printf -v expected 'create %q -> %q' "$PWD/target/$name" "$PWD/$name"
    output=$(dfl_link_apply)
    assertEquals 0 "$?"
    assertEquals "$expected" "$output"
    printf -v expected 'skip %q -> %q' "$PWD/target/$name" "$PWD/$name"
    output=$(dfl_link_apply)
    assertEquals 0 "$?"
    assertEquals "$expected" "$output"
}

test_link_apply_failure_does_not_log_success() {
    dfl_link_add source target/new
    local output code
    output=$(
        ln() { return 23; }
        dfl_link_apply
    )
    code=$?
    assertNotEquals 0 "$code"
    assertEquals '' "$output"
    assertFalse '[[ -L target/new ]]'
}

test_link_apply_log_failure_returns_failure() {
    dfl_link_add source target/new
    dfl_link_apply > /dev/full 2>/dev/null
    assertNotEquals 'Failed create output must propagate' 0 "$?"
    assertTrue '[[ -L target/new ]]'
    dfl_link_apply > /dev/full 2>/dev/null
    assertNotEquals 'Failed skip output must propagate' 0 "$?"
}


test_link_preview_reports_all_conflict_kinds() {
    mkdir directory
    printf other > other
    ln -s other different
    ln -s missing dangling
    printf blocked > parent
    ln -s source matching
    dfl_link_add source directory
    dfl_link_add source different
    dfl_link_add source dangling
    dfl_link_add missing missing-target
    dfl_link_add source parent/child
    dfl_link_add source matching
    dfl_link_add source new/config
    local output code
    output=$(_dfl_quiet=true dfl_link_preview)
    code=$?
    assertNotEquals 0 "$code"
    assertEquals "conflict $PWD/directory -> $PWD/source (destination already exists)
conflict $PWD/different -> $PWD/source (destination already exists)
conflict $PWD/dangling -> $PWD/source (destination already exists)
conflict $PWD/missing-target -> $PWD/missing (source does not exist)
conflict $PWD/parent/child -> $PWD/source (invalid destination)
skip $PWD/matching -> $PWD/source
create $PWD/new/config -> $PWD/source" "$output"
    assertFalse '[[ -e new || -e missing-target ]]'
    assertEquals other "$(readlink different)"
    assertEquals missing "$(readlink dangling)"
    assertEquals blocked "$(cat parent)"
}

test_link_preview_marks_only_later_overlapping_entries() {
    mkdir source-dir
    local order output
    for order in parent-first child-first; do
        dfl_link_reset
        if [[ $order == parent-first ]]; then
            dfl_link_add source-dir target
            dfl_link_add source target/config
        else
            dfl_link_add source target/config
            dfl_link_add source-dir target
        fi
        dfl_link_add source independent
        output=$(dfl_link_preview)
        assertNotEquals 0 "$?"
        assertEquals 1 "$(printf '%s\n' "$output" | grep -c '^conflict .* (overlapping destinations)$')"
        assertEquals 2 "$(printf '%s\n' "$output" | grep -c '^create ')"
        assertEquals create "$(printf '%s\n' "$output" | head -n 1 | cut -d ' ' -f 1)"
        assertEquals conflict "$(printf '%s\n' "$output" | sed -n '2s/ .*//p')"
        dfl_link_apply >/dev/null 2>&1
        assertNotEquals 0 "$?"
        assertFalse '[[ -e target || -e independent ]]'
    done
}

test_link_preview_detects_alias_overlaps_and_duplicates() {
    mkdir source-dir
    ln -s source-dir target
    ln -s source-dir alias
    dfl_link_add source-dir target
    dfl_link_add source alias/config
    dfl_link_add source source-dir/config
    local output
    output=$(dfl_link_preview)
    assertNotEquals 0 "$?"
    assertEquals 2 "$(printf '%s\n' "$output" | grep -c '^conflict .* (overlapping destinations)$')"
    assertFalse '[[ -e source-dir/config ]]'
    assertEquals source-dir "$(readlink target)"
}

test_link_preview_conflict_paths_are_escaped() {
    local name=$'conflict [*]\n' output expected
    printf old > "$name"
    dfl_link_add source "$name"
    printf -v expected 'conflict %q -> %q (destination already exists)' "$PWD/$name" "$PWD/source"
    output=$(dfl_link_preview)
    assertNotEquals 0 "$?"
    assertEquals "$expected" "$output"
    assertEquals 1 "$(printf '%s\n' "$output" | wc -l)"
}

test_link_preview_reports_all_under_strict_options() {
    printf old > conflict
    dfl_link_add source conflict
    dfl_link_add source new
    (
        set -euo pipefail
        dfl_link_preview
    ) > output
    assertNotEquals 0 "$?"
    assertEquals 2 "$(wc -l < output)"
    assertFalse '[[ -e new ]]'
}

test_link_preview_reports_one_reason_per_entry_and_continues() {
    printf old > conflict
    dfl_link_add missing conflict
    dfl_link_add source new
    local output
    output=$(dfl_link_preview)
    assertNotEquals 0 "$?"
    assertEquals "conflict $PWD/conflict -> $PWD/missing (source does not exist)
create $PWD/new -> $PWD/source" "$output"
    dfl_link_apply >/dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse '[[ -e new || -L new ]]'
    assertEquals old "$(cat conflict)"
}

test_link_preview_output_failure_is_returned() {
    dfl_link_add source new
    dfl_link_preview >/dev/full 2>/dev/null
    assertNotEquals 0 "$?"
    assertFalse '[[ -e new ]]'
}


script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../dotfiles-lib.sh"
# shellcheck source=/dev/null
source "${SHUNIT2:-/usr/share/shunit2/shunit2}"
