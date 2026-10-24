#!/usr/bin/env bash

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

setUp() {
    cd "$SHUNIT_TMPDIR" || return 1
    find . -name . -o -prune -exec rm -rf -- {} +
    fixture="$SHUNIT_TMPDIR/repo space"
    test_home="$SHUNIT_TMPDIR/home space"
    mkdir -p "$fixture/dotfiles"
    cp -R "$repo_dir/install.sh" "$repo_dir/vendor" "$fixture/"
    cp -R "$repo_dir/tests/fixtures/." "$fixture/dotfiles/"
}

run_install() {
    HOME="$test_home" bash "$fixture/install.sh" "$@" < /dev/null
}

test_selected_category_registers_links() {
    mkdir "$fixture/dotfiles/unselected"
    printf 'return 1\n' > "$fixture/dotfiles/unselected/links.sh"
    run_install link-category > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals "$fixture/dotfiles/link-category/input" "$(readlink "$test_home/config")"
}

test_dry_run_leaves_home_absent() {
    run_install --dry-run link-category > output 2>&1
    assertEquals 0 "$?"
    assertFalse "test -e '$test_home'"
    assertEquals 1 "$(grep -c '^create ' output)"
}

test_conflict_blocks_installers_even_with_force() {
    mkdir "$test_home"
    printf 'existing\n' > "$test_home/config"
    run_install --force installer-category link-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertEquals existing "$(cat "$test_home/config")"
    assertFalse "test -e '$test_home/installer-ran'"
}

test_unknown_category_prevents_changes() {
    run_install link-category nonexistent > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home'"
}

test_dry_run_does_not_execute_installers() {
    run_install --dry-run installer-category link-category > output 2>&1
    assertEquals 0 "$?"
    assertFalse "test -e '$test_home'"
    assertEquals 1 "$(grep -c '^legacy ' output)"
}

test_installer_runs_after_link_application() {
    run_install installer-category link-category > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals ran "$(cat "$test_home/installer-ran")"
    assertEquals "$fixture/dotfiles/link-category/input" "$(readlink "$test_home/config")"
}

test_installer_failure_is_returned() {
    mkdir "$fixture/dotfiles/failing"
    printf 'exit 23\n' > "$fixture/dotfiles/failing/install.sh"
    mkdir "$test_home"
    run_install failing installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home/installer-ran'"
}

test_options_are_passed_to_category_installers() {
    mkdir "$test_home"
    run_install --force --quiet installer-category > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals 'true true' "$(cat "$test_home/installer-options")"
}

test_cross_category_link_conflict_prevents_all_changes() {
    mkdir "$fixture/dotfiles/extra"
    cp "$fixture/dotfiles/link-category/links.sh" "$fixture/dotfiles/extra/links.sh"
    run_install link-category extra installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home'"
}

test_declaration_failure_prevents_all_changes() {
    mkdir "$fixture/dotfiles/failing"
    printf 'return 1\n' > "$fixture/dotfiles/failing/links.sh"
    run_install link-category failing installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home'"
}

test_declaration_command_failure_stops_installation() {
    cat > "$fixture/dotfiles/link-category/links.sh" <<'EOF'
false
printf reached > "$HOME/continued"
EOF
    mkdir "$test_home"
    run_install link-category installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home/continued'"
    assertFalse "test -e '$test_home/installer-ran'"
}

test_declaration_pipeline_failure_stops_installation() {
    cat > "$fixture/dotfiles/link-category/links.sh" <<'EOF'
false | cat
printf reached > "$HOME/continued"
EOF
    mkdir "$test_home"
    run_install link-category installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home/continued'"
    assertFalse "test -e '$test_home/installer-ran'"
}

test_declaration_unset_variable_stops_installation() {
    cat > "$fixture/dotfiles/link-category/links.sh" <<'EOF'
unset missing_test_variable
printf '%s' "$missing_test_variable" > "$HOME/continued"
EOF
    mkdir "$test_home"
    run_install link-category installer-category > /dev/null 2>&1
    assertNotEquals 0 "$?"
    assertFalse "test -e '$test_home/continued'"
    assertFalse "test -e '$test_home/installer-ran'"
}

# shellcheck source=/dev/null
source /usr/share/shunit2/shunit2
