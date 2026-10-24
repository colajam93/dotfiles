#!/usr/bin/env bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/../.." && pwd)"

setUp() {
    test_dir="$(mktemp -d "$SHUNIT_TMPDIR/install.XXXXXX")" || return 1
    mkdir -p "$test_dir/home" "$test_dir/repo/dotfiles/test-category" || return 1
    cp -a "$repo_dir/install.sh" "$repo_dir/vendor" "$test_dir/repo/" || return 1
    cat > "$test_dir/repo/dotfiles/test-category/install.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "$_dfl_force" "$_dfl_quiet" > "$HOME/options"
EOF
}

run_installer() (
    cd "$test_dir" || exit 1
    HOME="$test_dir/home" TERM=xterm bash "$test_dir/repo/install.sh" "$@"
)

test_category_from_another_directory() {
    run_installer test-category
    assertEquals 'The category must run successfully' 0 "$?"
    assertEquals 'false false' "$(cat "$test_dir/home/options")"
}

test_options_reach_category() {
    run_installer -f -q test-category
    assertEquals 0 "$?"
    assertEquals 'true true' "$(cat "$test_dir/home/options")"
}

test_missing_category_fails() {
    run_installer missing-category 2>/dev/null
    assertNotEquals 'Missing categories must fail' 0 "$?"
}

test_category_failure_stops_installation() {
    mkdir -p "$test_dir/repo/dotfiles/failing-category"
    printf 'exit 42\n' > "$test_dir/repo/dotfiles/failing-category/install.sh"
    run_installer failing-category test-category
    assertNotEquals 'Category failures must propagate' 0 "$?"
    assertFalse 'Later categories must not run' "test -e '$test_dir/home/options'"
}

test_entry_point_is_executable() {
    (
        cd "$test_dir/repo" || exit 1
        HOME="$test_dir/home" TERM=xterm ./install.sh test-category
    )
    assertEquals 'The entry point must be directly executable' 0 "$?"
    assertEquals 'false false' "$(cat "$test_dir/home/options")"
}

# shellcheck source=/dev/null
source "${SHUNIT2:-/usr/share/shunit2/shunit2}"
