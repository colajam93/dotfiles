_yellow=$(tput setaf 3)
_blue=$(tput setaf 4)
_reset=$(tput sgr0)

_gnu_readlink_f() {
    pushd $(pwd -P) > /dev/null 2>&1
    TARGET_FILE=$1
    while [[ "$TARGET_FILE" != "" ]]; do
        cd $(dirname $TARGET_FILE)
        FILENAME=$(basename $TARGET_FILE)
        TARGET_FILE=$(readlink $FILENAME)
    done

    echo "$(pwd -P)/$FILENAME"
    popd > /dev/null 2>&1
}

_overwrite_file() {
    local distfile_new=$1
    local distfile_old=$2
    mv $distfile_new $distfile_old
    print_information "mv $distfile_new $distfile_old"
}

print_warning() {
    echo "${_yellow}warning:${_reset} $1"
}

print_information() {
    echo "${_blue}information:${_reset} $1"
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
    local distfile
    if [[ -d $2 ]]; then
        local filename=$(basename $srcfile)
        distfile=$(_gnu_readlink_f $2/$filename)
    else
        distfile=$(_gnu_readlink_f $2)
    fi

    # if argc == 3, use it as permission mode which pass to install -m
    local permission='644'
    if [[ $# -eq 3 ]]; then
        permission=$3
    fi

    # overwrite check
    if $(cmp -s $srcfile $distfile); then
    # same file
        print_information "skipped ${distfile}"
        return 0
    elif [[ -e $distfile ]]; then
    # distfile already exists
        print_warning "${distfile} saved as ${distfile}.dotnew"
        local distfile_old=$distfile
        local distfile_new=$distfile.dotnew
        distfile=$distfile.dotnew
    fi

    print_information "installed in ${distfile}"
    install -m $permission $srcfile $distfile

    if [[ $distfile_new != '' ]]; then
        if [[ "$_dotfiles_force" = true ]]; then
            _overwrite_file $distfile_new $distfile_old
        else
            if type colordiff > /dev/null 2>&1; then
                diff_command='colordiff'
            else
                diff_command='diff'
            fi
            eval "$diff_command -u $distfile_old $distfile_new"
            echo "overwrite $distfile_old by new file? [y/N]"
            read input
            if [[ $input == 'y' ]]; then
                _overwrite_file $distfile_new $distfile_old
            fi
        fi
    fi
}

dotfile_install() {
    if [[ $# -ne 2 ]]; then
        return 1
    fi

    # destination file
    local distfile
    if ! [[ $1 == .* ]] && [[ -d $2 ]]; then
        # src is not dotfile and dist is directory
        local filename=$(basename $1)
        distfile=$(_gnu_readlink_f $2/.$filename)
    else
        # do nothing
        distfile=$2
    fi

    safe_install $1 $distfile
}
