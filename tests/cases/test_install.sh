#!/usr/bin/env bash

oneTimeSetUp() {
    export LIBSS_TEST_CONTENT="foo"
    export LIBSS_TEST_INPUT="input"
}

oneTimeTearDown() {
    unset LIBSS_TEST_CONTENT
    unset LIBSS_TEST_INPUT
}

setUp() {
    cd "$SHUNIT_TMPDIR" || return 1
    find . -name . -o -prune -exec rm -rf -- {} +
    echo "$LIBSS_TEST_CONTENT" > "$LIBSS_TEST_INPUT"
}

test_safe_install_source_missing() {
    local code
    local result
    result=$(dfl_safe_install missing bar)
    code=$?
    assertEquals 1 "$code"
    assertEquals "missing: No such file or directory" "$result"
}

test_safe_install_invalid_permission() {
    dfl_safe_install "$LIBSS_TEST_INPUT" moved invalid-mode &> /dev/null
    local code=$?

    assertNotEquals 'A failed copy must return nonzero' 0 "$code"
    assertFalse "[[ -e moved ]]"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat "$LIBSS_TEST_INPUT")"
}

test_safe_install_destination_file() {
    # output include path resolve so test is omitted
    dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    assertTrue "[[ -f moved ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content=$(<moved)
    assertEquals "$LIBSS_TEST_CONTENT" "$content"
}

test_safe_install_destination_directory() {
    mkdir d
    # output include path resolve so test is omitted
    dfl_safe_install "$LIBSS_TEST_INPUT" d &> /dev/null
    assertTrue "[[ -f d/$LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content="$(<"d/$LIBSS_TEST_INPUT")"
    assertEquals "$LIBSS_TEST_CONTENT" "$content"
}

test_safe_install_source_symlink() {
    mkdir source destination
    ln -s "../$LIBSS_TEST_INPUT" source/link

    dfl_safe_install source/link destination &> /dev/null

    assertTrue "[[ -L source/link ]]"
    assertTrue "[[ -f destination/$LIBSS_TEST_INPUT ]]"
    assertFalse "[[ -e destination/link ]]"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat "destination/$LIBSS_TEST_INPUT")"
}

test_safe_install_destination_symlink() {
    mkdir destination
    echo old > destination/target
    ln -s target destination/link

    _dfl_force=true dfl_safe_install "$LIBSS_TEST_INPUT" destination/link &> /dev/null

    assertTrue "[[ -L destination/link ]]"
    assertEquals "target" "$(readlink destination/link)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat destination/target)"
    assertFalse "[[ -e destination/target.dotnew ]]"
}

test_safe_install_destination_dangling_symlink() {
    mkdir destination
    ln -s target destination/link

    dfl_safe_install "$LIBSS_TEST_INPUT" destination/link &> /dev/null

    assertTrue "[[ -L destination/link ]]"
    assertEquals "target" "$(readlink destination/link)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat destination/target)"
}

test_safe_install_destination_parent_missing() {
    local code
    dfl_safe_install "$LIBSS_TEST_INPUT" missing/target &> /dev/null
    code=$?

    assertNotEquals 0 "$code"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat "$LIBSS_TEST_INPUT")"
    assertEquals "./$LIBSS_TEST_INPUT" "$(find . -mindepth 1 -print)"
}

test_safe_install_destination_parent_symlink() {
    mkdir destination
    ln -s destination linked

    dfl_safe_install "$LIBSS_TEST_INPUT" linked/target &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertTrue "[[ -L linked ]]"
    assertEquals "destination" "$(readlink linked)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat destination/target)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat "$LIBSS_TEST_INPUT")"
}

test_safe_install_destination_permission() {
    # output include path resolve so test is omitted
    dfl_safe_install "$LIBSS_TEST_INPUT" moved 456 &> /dev/null
    assertTrue "[[ -f moved ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content="$(<moved)"
    assertEquals "$LIBSS_TEST_CONTENT" "$content"
    assertEquals "456" "$(stat -c %a moved)"
}

test_safe_install_destination_permission_default() {
    # output include path resolve so test is omitted
    dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    assertTrue "[[ -f moved ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content="$(<moved)"
    assertEquals "$LIBSS_TEST_CONTENT" "$content"
    assertEquals "644" "$(stat -c %a moved)"
}


test_safe_install_skip() {
    echo "$LIBSS_TEST_CONTENT" > moved
    chmod 600 moved
    touch -d '2000-01-01 00:00:00 UTC' moved
    local before code
    before=$(stat -c '%i:%y:%a' moved)

    dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    code=$?

    assertEquals 0 "$code"
    assertTrue "[[ -f moved ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved)"
    assertEquals 'Existing file metadata must not change' "$before" "$(stat -c '%i:%y:%a' moved)"
    assertFalse "[[ -e moved.dotnew ]]"
}

libss_test_safe_install_not_overwrite() {
    echo "${LIBSS_TEST_CONTENT}_bar" > moved

    printf "%s\n" "$1" | dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    assertTrue "[[ -f moved ]]"
    assertTrue "[[ -f moved.dotnew ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"

    local content_old
    content_old="$(<moved)"
    assertEquals "$content_old" "${LIBSS_TEST_CONTENT}_bar"
    local content_new
    content_new="$(<moved.dotnew)"
    assertEquals "$content_new" "$LIBSS_TEST_CONTENT"
}

test_safe_install_not_overwrite1() {
    libss_test_safe_install_not_overwrite
}

test_safe_install_not_overwrite2() {
    libss_test_safe_install_not_overwrite "\n"
}

test_safe_install_not_overwrite3() {
    libss_test_safe_install_not_overwrite "n"
}

test_safe_install_not_overwrite4() {
    libss_test_safe_install_not_overwrite "N"
}

test_safe_install_not_overwrite5() {
    libss_test_safe_install_not_overwrite "m"
}

test_safe_install_not_overwrite_backslash_y() {
    libss_test_safe_install_not_overwrite '\y'
}

test_safe_install_not_overwrite_eof() {
    echo "${LIBSS_TEST_CONTENT}_bar" > moved

    dfl_safe_install "$LIBSS_TEST_INPUT" moved < /dev/null &> /dev/null

    assertEquals "${LIBSS_TEST_CONTENT}_bar" "$(cat moved)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved.dotnew)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat "$LIBSS_TEST_INPUT")"
}

libss_test_safe_install_overwrite_prepare() {
    echo "${LIBSS_TEST_CONTENT}_bar" > moved
}

libss_test_safe_install_overwrite_check() {
    assertTrue "[[ -f moved ]]"
    assertFalse "[[ -f moved.dotnew ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content="$(<moved)"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
}

test_safe_install_overwrite() {
    libss_test_safe_install_overwrite_prepare
    echo y | dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    libss_test_safe_install_overwrite_check
}

test_safe_install_overwrite_force() {
    export _dfl_force=true
    libss_test_safe_install_overwrite_prepare
    dfl_safe_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    libss_test_safe_install_overwrite_check
    unset _dfl_force
}

test_dotfile_install_missing_argument() {
    local code
    dfl_dotfile_install
    code=$?
    assertTrue "[[ $code -eq 1 ]]"
    dfl_dotfile_install foo
    code=$?
    assertTrue "[[ $code -eq 1 ]]"
    dfl_dotfile_install foo bar baz
    code=$?
    assertTrue "[[ $code -eq 1 ]]"
}

test_dotfile_install_normal_to_directory() {
    dfl_dotfile_install "$LIBSS_TEST_INPUT" "$SHUNIT_TMPDIR" &> /dev/null
    assertTrue "[[ -f .$LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    local content
    content="$(<".$LIBSS_TEST_INPUT")"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
}

test_dotfile_install_normal_to_file() {
    dfl_dotfile_install "$LIBSS_TEST_INPUT" moved &> /dev/null
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f moved ]]"
    local content
    content="$(<moved)"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
}

test_dotfile_install_dotfile_to_directory() {
    mkdir d
    echo "$LIBSS_TEST_CONTENT" > .dot
    dfl_dotfile_install .dot d &> /dev/null
    assertTrue "[[ -f .dot ]]"
    assertTrue "[[ -f d/.dot ]]"
    local content
    content="$(<d/.dot)"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
}

test_dotfile_install_dotfile_to_file() {
    echo "$LIBSS_TEST_CONTENT" > .dot
    dfl_dotfile_install .dot moved &> /dev/null
    assertTrue "[[ -f .dot ]]"
    assertTrue "[[ -f moved ]]"
    local content
    content="$(<moved)"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
}

test_install_all_source_directory_missing() {
    mkdir destination
    printf '%s\n' original > destination/existing

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/missing" &> /dev/null
    local code=$?

    assertNotEquals 'A missing source directory must return nonzero' 0 "$code"
    assertEquals existing "$(find destination -mindepth 1 -printf '%f\n')"
    assertEquals original "$(cat destination/existing)"
}

test_install_all_one() {
    mkdir d
    tmp_home=$HOME
    export HOME="$SHUNIT_TMPDIR/d"
    dfl_install_all "$SHUNIT_TMPDIR" &> /dev/null
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.$LIBSS_TEST_INPUT ]]"
    local content
    content="$(<"$SHUNIT_TMPDIR/d/.$LIBSS_TEST_INPUT")"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
    export HOME=$tmp_home
}

test_install_all_some() {
    echo "${LIBSS_TEST_CONTENT}_a" > a
    echo "${LIBSS_TEST_CONTENT}_b" > b
    mkdir d
    tmp_home=$HOME
    export HOME="$SHUNIT_TMPDIR/d"
    dfl_install_all "$SHUNIT_TMPDIR" &> /dev/null
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f a ]]"
    assertTrue "[[ -f b ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.$LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.a ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.b ]]"
    local content
    content="$(<"$SHUNIT_TMPDIR/d/.$LIBSS_TEST_INPUT")"
    assertEquals "$content" "$LIBSS_TEST_CONTENT"
    content="$(<"$SHUNIT_TMPDIR/d/.a")"
    assertEquals "$content" "${LIBSS_TEST_CONTENT}_a"
    content="$(<"$SHUNIT_TMPDIR/d/.b")"
    assertEquals "$content" "${LIBSS_TEST_CONTENT}_b"
    export HOME=$tmp_home
}

test_safe_install_paths_with_spaces() {
    mkdir 'source dir' 'destination dir'
    printf '%s\n' "$LIBSS_TEST_CONTENT" > 'source dir/input [1]'
    printf '%s\n' old > 'destination dir/input [1]'

    _dfl_force=true dfl_safe_install 'source dir/input [1]' 'destination dir' &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat 'source dir/input [1]')"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat 'destination dir/input [1]')"
    assertFalse "[[ -e 'destination dir/input [1].dotnew' ]]"
}

test_install_all_special_filenames() {
    mkdir 'source dir' 'home dir'
    local name
    for name in 'space name' 'glob [1]*' $'line\nbreak' '-leading'; do
        printf '%s\n' "$LIBSS_TEST_CONTENT" > "source dir/$name"
    done
    printf '%s\n' excluded > 'source dir/skip me'
    printf '%s\n' excluded > 'source dir/install.sh'
    printf '%s\n' excluded > 'source dir/.foo.swp'

    HOME="$SHUNIT_TMPDIR/home dir" dfl_install_all "$SHUNIT_TMPDIR/source dir" 'skip me' &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    for name in 'space name' 'glob [1]*' $'line\nbreak' '-leading'; do
        assertEquals "$name" "$LIBSS_TEST_CONTENT" "$(cat "home dir/.$name")"
    done
    assertFalse "[[ -e 'home dir/.skip me' ]]"
    assertFalse "[[ -e 'home dir/.install.sh' ]]"
    assertFalse "[[ -e 'home dir/..foo.swp' ]]"
}

test_install_all_multiple_excludes() {
    mkdir source destination
    local name
    for name in first second keep; do
        printf '%s\n' "$name" > "source/$name"
    done

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" first second &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertFalse "[[ -e destination/.first ]]"
    assertFalse "[[ -e destination/.second ]]"
    assertEquals keep "$(cat destination/.keep)"
}

test_install_all_exclude_suffix() {
    mkdir source destination
    local name
    for name in skip prefix_skip skip.backup keep; do
        printf '%s\n' "$name" > "source/$name"
    done

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" skip &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertFalse "[[ -e destination/.skip ]]"
    assertFalse "[[ -e destination/.prefix_skip ]]"
    assertEquals skip.backup "$(cat destination/.skip.backup)"
    assertEquals keep "$(cat destination/.keep)"
}

test_install_all_exclude_regex() {
    mkdir source destination
    local name
    for name in alpha.conf beta.conf alpha.conf.backup alphaxconf gamma.conf; do
        printf '%s\n' "$name" > "source/$name"
    done

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" '(alpha|beta)\.conf' &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertFalse "[[ -e destination/.alpha.conf ]]"
    assertFalse "[[ -e destination/.beta.conf ]]"
    for name in alpha.conf.backup alphaxconf gamma.conf; do
        assertEquals "$name" "$(cat "destination/.$name")"
    done
}

test_install_all_exclude_argument_boundaries() {
    mkdir source together separate
    local name
    for name in 'first second' first second keep; do
        printf '%s\n' "$name" > "source/$name"
    done

    HOME="$SHUNIT_TMPDIR/together" dfl_install_all "$SHUNIT_TMPDIR/source" 'first second' &> /dev/null
    local code=$?
    assertEquals 0 "$code"
    assertFalse "[[ -e 'together/.first second' ]]"
    assertEquals first "$(cat together/.first)"
    assertEquals second "$(cat together/.second)"
    assertEquals keep "$(cat together/.keep)"

    HOME="$SHUNIT_TMPDIR/separate" dfl_install_all "$SHUNIT_TMPDIR/source" first second &> /dev/null
    code=$?
    assertEquals 0 "$code"
    assertFalse "[[ -e separate/.first ]]"
    assertFalse "[[ -e separate/.second ]]"
    # 'first second' also matches the suffix 'second'.
    assertFalse "[[ -e 'separate/.first second' ]]"
    assertEquals keep "$(cat separate/.keep)"
}

test_install_all_exclude_matches_source_path() {
    mkdir source destination
    printf '%s\n' excluded > source/skip
    printf '%s\n' keep > source/keep

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" '/source/skip' &> /dev/null
    local code=$?

    assertEquals 0 "$code"
    assertFalse "[[ -e destination/.skip ]]"
    assertEquals keep "$(cat destination/.keep)"
}

test_install_all_invalid_exclusion_regex() {
    mkdir source destination
    printf '%s\n' updated > source/config
    printf '%s\n' new > source/new
    printf '%s\n' original > destination/.config

    HOME="$SHUNIT_TMPDIR/destination" _dfl_force=true \
        dfl_install_all "$SHUNIT_TMPDIR/source" '[' < /dev/null &> /dev/null
    local code=$?

    assertNotEquals 'An invalid exclusion must return nonzero' 0 "$code"
    assertEquals 'Existing files must not change' original "$(cat destination/.config)"
    assertFalse 'No files may be added for an invalid exclusion' "[[ -e destination/.new ]]"
    assertFalse "[[ -e destination/.config.dotnew ]]"
}

test_install_all_invalid_exclusion_regex_empty_directory() {
    mkdir source destination

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" '[' &> /dev/null
    local code=$?

    assertNotEquals 'Exclusions must be validated even without source files' 0 "$code"
    assertEquals '' "$(find destination -mindepth 1 -print)"
}

test_install_all_preserves_errexit_on_success() {
    mkdir source destination
    printf '%s\n' content > source/config
    local option code
    for option in -e +e; do
        HOME="$SHUNIT_TMPDIR/destination" bash "$option" -c '
            source "$1"
            before=$-
            dfl_install_all "$2" "unused"
            code=$?
            [[ $code -eq 0 && $- == "$before" ]]
        ' bash "$script_dir/../../dotfiles-lib.sh" "$SHUNIT_TMPDIR/source" &> /dev/null
        code=$?
        assertEquals "Caller shell options must be preserved ($option)" 0 "$code"
        assertEquals content "$(cat destination/.config)"
    done
}

test_install_all_preserves_errexit_on_invalid_regex() {
    mkdir source destination
    printf '%s\n' content > source/config
    local option code
    for option in -e +e; do
        HOME="$SHUNIT_TMPDIR/destination" bash "$option" -c '
            source "$1"
            before=$-
            if dfl_install_all "$2" "["; then
                exit 1
            fi
            [[ $- == "$before" ]]
        ' bash "$script_dir/../../dotfiles-lib.sh" "$SHUNIT_TMPDIR/source" &> /dev/null
        code=$?
        assertEquals "Caller shell options must be preserved ($option)" 0 "$code"
        assertEquals '' "$(find destination -mindepth 1 -print)"
    done
}

test_install_all_no_selected_files() {
    mkdir source destination

    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" &> /dev/null
    local code=$?
    assertEquals 0 "$code"
    assertEquals '' "$(find destination -mindepth 1 -print)"

    touch source/install.sh source/.foo.swp source/skip
    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all "$SHUNIT_TMPDIR/source" skip &> /dev/null
    code=$?
    assertEquals 0 "$code"
    assertEquals '' "$(find destination -mindepth 1 -print)"
}

test_install_all_exclude() {
    echo "${LIBSS_TEST_CONTENT}_a" > a
    echo "${LIBSS_TEST_CONTENT}_b" > b
    touch 'install.sh'
    touch '.foo.swp'
    mkdir d
    tmp_home=$HOME
    export HOME="$SHUNIT_TMPDIR/d"
    dfl_install_all "$SHUNIT_TMPDIR" a &> /dev/null
    assertTrue "[[ -f $LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f a ]]"
    assertTrue "[[ -f b ]]"
    assertTrue "[[ -f install.sh ]]"
    assertTrue "[[ -f .foo.swp ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.$LIBSS_TEST_INPUT ]]"
    assertTrue "[[ -f $SHUNIT_TMPDIR/d/.b ]]"
    assertFalse "[[ -f $SHUNIT_TMPDIR/d/.a ]]"
    assertFalse "[[ -f $SHUNIT_TMPDIR/d/.install.sh ]]"
    assertFalse "[[ -f $SHUNIT_TMPDIR/d/.foo.swp ]]"
    export HOME=$tmp_home
}

test_install_vim_layout() {
    mkdir source home config
    local name
    for name in vimrc plugins.toml plugins_lazy.toml; do
        printf '%s\n' "$name" > "source/$name"
    done
    touch source/install.sh

    dfl_safe_install source/plugins.toml config &> /dev/null
    assertEquals 0 "$?"
    dfl_safe_install source/plugins_lazy.toml config &> /dev/null
    assertEquals 0 "$?"
    HOME="$SHUNIT_TMPDIR/home" dfl_install_all "$SHUNIT_TMPDIR/source" plugins.toml plugins_lazy.toml &> /dev/null
    assertEquals 0 "$?"
    dfl_safe_install source/vimrc config/init.vim &> /dev/null
    assertEquals 0 "$?"

    assertEquals vimrc "$(cat home/.vimrc)"
    assertEquals vimrc "$(cat config/init.vim)"
    assertEquals plugins.toml "$(cat config/plugins.toml)"
    assertEquals plugins_lazy.toml "$(cat config/plugins_lazy.toml)"
    assertFalse "[[ -e home/.plugins.toml ]]"
    assertFalse "[[ -e home/.plugins_lazy.toml ]]"
    assertFalse "[[ -e home/.install.sh ]]"
}

test_print_messages() {
    assertEquals "$(tput setaf 1)error:$(tput sgr0) failure" "$(dfl_print_error failure)"
    assertEquals "$(tput setaf 3)warning:$(tput sgr0) warning" "$(dfl_print_warning warning)"
    assertEquals "$(tput setaf 4)information:$(tput sgr0) progress" "$(dfl_print_information progress)"
}

test_print_messages_quiet() {
    local output code
    output=$(
        _dfl_quiet=true dfl_print_error failure
        _dfl_quiet=true dfl_print_warning warning
        _dfl_quiet=true dfl_print_information progress
    )
    code=$?
    assertEquals 0 "$code"
    assertEquals '' "$output"
}

test_safe_install_quiet() {
    local output code
    output=$(_dfl_quiet=true dfl_safe_install "$LIBSS_TEST_INPUT" moved)
    code=$?
    assertEquals 0 "$code"
    assertEquals '' "$output"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved)"
}

test_platform_name_linux() {
    # The supported test environment is the Linux Docker image.
    assertEquals linux "$(dfl_platform_name)"
}

test_installed() {
    dfl_installed bash
    assertEquals 0 "$?"
    dfl_installed dfl_test_nonexistent_command
    assertNotEquals 0 "$?"
}

test_install_all_accepts_confirmation_for_each_file() {
    mkdir source destination
    printf 'new a\n' > source/a
    printf 'new b\n' > source/b
    printf 'old a\n' > destination/.a
    printf 'old b\n' > destination/.b
    printf 'y\ny\n' | HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals 'new a' "$(cat destination/.a)"
    assertEquals 'new b' "$(cat destination/.b)"
    assertFalse '[[ -e destination/.a.dotnew || -e destination/.b.dotnew ]]'
}

test_install_all_rejects_confirmation_for_each_file() {
    mkdir source destination
    printf 'new a\n' > source/a
    printf 'new b\n' > source/b
    printf 'old a\n' > destination/.a
    printf 'old b\n' > destination/.b
    printf 'n\nn\n' | HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals 'old a' "$(cat destination/.a)"
    assertEquals 'old b' "$(cat destination/.b)"
    assertEquals 'new a' "$(cat destination/.a.dotnew)"
    assertEquals 'new b' "$(cat destination/.b.dotnew)"
}

test_install_all_preserves_files_on_confirmation_eof() {
    mkdir source destination
    printf 'new a\n' > source/a
    printf 'new b\n' > source/b
    printf 'old a\n' > destination/.a
    printf 'old b\n' > destination/.b
    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source < /dev/null > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals 'old a' "$(cat destination/.a)"
    assertEquals 'old b' "$(cat destination/.b)"
    assertEquals 'new a' "$(cat destination/.a.dotnew)"
    assertEquals 'new b' "$(cat destination/.b.dotnew)"
}

test_safe_install_reports_overwrite_failure() {
    printf 'old\n' > moved
    local force code
    for force in true false; do
        (
            mv() { return 1; }
            printf 'y\n' | _dfl_force="$force" dfl_safe_install "$LIBSS_TEST_INPUT" moved
        ) > output 2>&1
        code=$?
        assertNotEquals 'Failed replacement must return nonzero' 0 "$code"
        assertEquals old "$(cat moved)"
        assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved.dotnew)"
        assertFalse 'grep -q "information:.*mv " output'
    done
}

test_install_all_stops_on_copy_failure() {
    mkdir source destination
    printf 'unreadable\n' > source/a
    printf 'later\n' > source/b
    chmod 000 source/a
    (
        # Fix traversal order so a failing copy precedes a valid one.
        find() { command find "$@" | sort -z; }
        HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source
    ) > /dev/null 2>&1
    local code=$?
    chmod 644 source/a
    assertNotEquals 'A failed copy must not be hidden by later success' 0 "$code"
    assertFalse '[[ -e destination/.a ]]'
    assertFalse '[[ -e destination/.b ]]'
}

test_install_all_reports_directory_read_failure() {
    mkdir source destination
    printf 'config\n' > source/config
    chmod 000 source
    HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source > /dev/null 2>&1
    local code=$?
    chmod 755 source
    assertNotEquals 'An unreadable source directory must fail' 0 "$code"
    assertEquals '' "$(find destination -mindepth 1 -print)"
}

test_install_all_rejects_incomplete_file_listing() {
    mkdir source destination
    printf 'config\n' > source/config
    (
        find() { command find "$@"; return 1; }
        HOME="$SHUNIT_TMPDIR/destination" dfl_install_all source
    ) > /dev/null 2>&1
    local code=$?
    assertNotEquals 'A partial listing must not be treated as success' 0 "$code"
    assertEquals '' "$(find destination -mindepth 1 -print)"
}

test_safe_install_accepts_confirmation_with_errexit() {
    printf 'old\n' > moved
    printf 'y\n' | bash -e -c '
        source "$1"
        dfl_safe_install "$2" moved
        printf continued > continued
    ' bash "$script_dir/../../dotfiles-lib.sh" "$LIBSS_TEST_INPUT" > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved)"
    assertFalse '[[ -e moved.dotnew ]]'
    assertTrue '[[ -e continued ]]'
}

test_safe_install_declines_eof_with_errexit() {
    printf 'old\n' > moved
    bash -e -c '
        source "$1"
        dfl_safe_install "$2" moved
        printf continued > continued
    ' bash "$script_dir/../../dotfiles-lib.sh" "$LIBSS_TEST_INPUT" < /dev/null > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals old "$(cat moved)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved.dotnew)"
    assertTrue '[[ -e continued ]]'
}

test_safe_install_stops_if_diff_fails() {
    printf 'old\n' > moved
    (
        diff() { return 2; }
        printf 'y\n' | dfl_safe_install "$LIBSS_TEST_INPUT" moved
    ) > output 2>&1
    local code=$?
    assertNotEquals 'A comparison error must stop installation' 0 "$code"
    assertEquals old "$(cat moved)"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved.dotnew)"
    assertFalse 'grep -q "overwrite .*by new file" output'
}

test_safe_install_creates_file_with_nounset() {
    bash -eu -c '
        source "$1"
        dfl_safe_install "$2" moved
        printf continued > continued
    ' bash "$script_dir/../../dotfiles-lib.sh" "$LIBSS_TEST_INPUT" > /dev/null 2>&1
    assertEquals 0 "$?"
    assertEquals "$LIBSS_TEST_CONTENT" "$(cat moved)"
    assertFalse '[[ -e moved.dotnew ]]'
    assertTrue '[[ -e continued ]]'
}

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [[ -f "${SHUNIT2:-/usr/share/shunit2/shunit2}" ]]; then
    echo "fatal: shunit2 not found"
    exit 1
fi

source "$script_dir/../../dotfiles-lib.sh"
# shellcheck source=/dev/null
source "${SHUNIT2:-/usr/share/shunit2/shunit2}"
