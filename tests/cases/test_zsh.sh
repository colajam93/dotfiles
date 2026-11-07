#!/usr/bin/env bash

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

setUp() {
    fixture=$(mktemp -d "$SHUNIT_TMPDIR/zsh.XXXXXX")
    mkdir -p "$fixture/.shell" "$fixture/bin"
    ln -s "$repo_dir/dotfiles/shell/zsh" "$fixture/.shell/zsh"
    ln -s "$repo_dir/dotfiles/shell/common.sh" "$fixture/.shell/common.sh"
}

run_zsh() {
    env -i HOME="$fixture" ZDOTDIR="$fixture" TERM=xterm-256color \
        PATH="$fixture/bin:/usr/bin:/bin" LC_ALL=C.UTF-8 \
        DOTFILES_REPO="$repo_dir" \
        zsh -d -f -i -c "$(cat)" > "$fixture/output" 2> "$fixture/error"
}

test_history_settings_preserve_existing_limits_and_file() {
    run_zsh <<'ZSH'
        HISTFILE=$HOME/custom-history HISTSIZE=90000 SAVEHIST=40000
        source "$HOME/.shell/zsh/history.zsh"
        [[ $HISTFILE == $HOME/custom-history && $HISTSIZE == 90000 && $SAVEHIST == 40000 ]] || exit 1
        unset HISTFILE; SAVEHIST=0
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
}

test_completion_excludes_insecure_directory_and_notifies() {
    mkdir -p "$fixture/insecure"
    printf '#compdef forbidden-command\nreturn 0\n' > "$fixture/insecure/_forbidden"
    chmod 777 "$fixture/insecure"
    run_zsh <<'ZSH'
        fpath=("$HOME/insecure" $fpath)
        source "$HOME/.shell/zsh/completion.zsh"
        [[ -z ${_comps[forbidden-command]-} ]] || exit 1
        [[ -n ${_comps[ls]-} ]] || exit 2
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
    assertTrue "grep -q insecure '$fixture/error'"
}

test_terminal_uri_encoding_and_ssh_suppression() {
    run_zsh <<'ZSH'
        source "$HOME/.shell/zsh/terminal.zsh"
        _dotfiles_uri_encode $'/a b/#%\001日本'
        [[ $REPLY == /a%20b/%23%25%01%E6%97%A5%E6%9C%AC ]] || exit 1
        [[ ${precmd_functions[(Ie)_dotfiles_terminal_cwd]} -gt 0 ]] || exit 2
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
    run_zsh <<'ZSH'
        SSH_CLIENT=example
        source "$HOME/.shell/zsh/terminal.zsh"
        [[ ${precmd_functions[(Ie)_dotfiles_terminal_cwd]} == 0 ]] || exit 1
        [[ ${precmd_functions[(Ie)_dotfiles_terminal_precmd]} -gt 0 ]] || exit 2
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
}

test_startup_without_omz_and_with_optional_tools_missing() {
    run_zsh <<'ZSH'
        source "$HOME/.shell/zsh/init.zsh"
        [[ -n ${_comps[ls]-} ]] || exit 1
        [[ -n $PROMPT ]] || exit 5
        unset HISTFILE; SAVEHIST=0
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
}

test_aws_completion_is_registered_after_mise_activation() {
    mkdir -p "$fixture/.local/bin" "$fixture/aws-bin"
    cat > "$fixture/.local/bin/mise" <<'STUB'
#!/bin/sh
printf 'export PATH="%s/aws-bin:$PATH"\n' "$HOME"
STUB
    printf '#!/bin/sh\nexit 0\n' > "$fixture/aws-bin/aws_completer"
    chmod +x "$fixture/.local/bin/mise" "$fixture/aws-bin/aws_completer"
    run_zsh <<'ZSH'
        source "$HOME/.shell/zsh/init.zsh"
        [[ $(complete -p aws) == *aws_completer* ]] || exit 1
        unset HISTFILE; SAVEHIST=0
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
}

test_pager_exports_and_title_control_characters() {
    run_zsh <<'ZSH'
        export PAGER="" LESS="custom"
        source "$HOME/.shell/zsh/options.zsh"
        [[ -z $PAGER && $LESS == custom ]] || exit 1
        source "$HOME/.shell/zsh/terminal.zsh"
        _dotfiles_title $'tab\aINJECT' $'window\ntext' > "$HOME/title"
        [[ $(<"$HOME/title") == $'\e]2;windowtext\a\e]1;tabINJECT\a' ]] || exit 2
ZSH
    result=$?
    assertEquals "$(cat "$fixture/error")" 0 "$result"
}

. "${SHUNIT2:-/usr/share/shunit2/shunit2}"
