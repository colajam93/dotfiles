_yellow=$(tput setaf 3 2> /dev/null)
_blue=$(tput setaf 4 2> /dev/null)
_reset=$(tput sgr0 2> /dev/null)

_gnu_readlink_f() {
    pushd $(pwd -P) > /dev/null 2>&1
    local TARGET_FILE=$1
    while [[ "$TARGET_FILE" != "" ]]; do
        cd $(dirname $TARGET_FILE)
        local FILENAME=$(basename $TARGET_FILE)
        TARGET_FILE=$(readlink $FILENAME)
    done

    echo "$(pwd -P)/$FILENAME"
    popd > /dev/null 2>&1
}

_overwrite_file() {
    local destfile_new=$1
    local destfile_old=$2
    mv $destfile_new $destfile_old
    print_information "mv $destfile_new $destfile_old"
}

_backward_match() {
    local i
    for i in $@; do
        printf "%s$\n" $i
    done
}

join() {
    local d=$1
    shift
    if [[ $# -eq 0 ]]; then
        echo ''
        return 1
    fi
    echo -n "$1"
    shift
    printf "%s" "${@/#/$d}"
}

print_warning() {
    if [[ "$_dotfiles_quiet" = false ]]; then
        echo "${_yellow}warning:${_reset} $1"
    fi
}

print_information() {
    if [[ "$_dotfiles_quiet" = false ]]; then
        echo "${_blue}information:${_reset} $1"
    fi
}

safe_install() {
    # source file
    if [[ -e $1 ]]; then
        local srcfile=$(_gnu_readlink_f $1)
    else
        echo "$1: No such file or directory"
        return 1
    fi
        
    # destination file
    local destfile
    if [[ -d $2 ]]; then
        local filename=$(basename $srcfile)
        destfile=$(_gnu_readlink_f $2/$filename)
    else
        destfile=$(_gnu_readlink_f $2)
    fi

    # if argc == 3, use it as permission mode which pass to install -m
    local permission='644'
    if [[ $# -eq 3 ]]; then
        permission=$3
    fi

    # overwrite check
    if $(cmp -s $srcfile $destfile); then
    # same file
        print_information "skipped ${destfile}"
        return 0
    elif [[ -e $destfile ]]; then
    # destfile already exists
        print_warning "${destfile} saved as ${destfile}.dotnew"
        local destfile_old=$destfile
        local destfile_new=$destfile.dotnew
        destfile=$destfile.dotnew
    fi

    print_information "installed in ${destfile}"
    install -m $permission $srcfile $destfile

    if [[ $destfile_new != '' ]]; then
        if [[ "$_dotfiles_force" = true ]]; then
            _overwrite_file $destfile_new $destfile_old
        else
            local diff_command
            if type colordiff > /dev/null 2>&1; then
                diff_command='colordiff'
            else
                diff_command='diff'
            fi
            eval "$diff_command -u $destfile_old $destfile_new"
            echo "overwrite $destfile_old by new file? [y/N]"
            local input
            read input
            if [[ $input == 'y' ]]; then
                _overwrite_file $destfile_new $destfile_old
            fi
        fi
    fi
}

dotfile_install() {
    if [[ $# -ne 2 ]]; then
        return 1
    fi

    # destination file
    local destfile
    if ! [[ $1 == .* ]] && [[ -d $2 ]]; then
        # src is not dotfile and dest is directory
        local filename=$(basename $1)
        destfile=$(_gnu_readlink_f $2/.$filename)
    else
        # do nothing
        destfile=$2
    fi

    safe_install $1 $destfile
}

install_all() {
    local target_dir=$1
    shift
    local excludes="$(join '|' $(_backward_match 'install.sh' $@))"
    local i
    for i in $(find $target_dir -maxdepth 1 -type f | egrep -v $excludes); do
        dotfile_install "$(_gnu_readlink_f $i)" $HOME
    done
}
