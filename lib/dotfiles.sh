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

print_warning() {
    echo "${_yellow}warning:${_reset} $1"
}

print_information() {
    echo "${_blue}information:${_reset} $1"
}

safe_install() {
    # check argc
    if [[ $# -ne 2 ]]; then
        echo 'usage: safe_install [src] [dist]'
        return 1
    fi

    # source file
    if [[ -e $1 ]]; then
        srcfile=$(_gnu_readlink_f $1)
    else
        echo "$1: No such file or directory"
        return 1
    fi
        
    # destination file
    if [[ -d $2 ]]; then
        filename=$(basename $srcfile)
        distfile=$(_gnu_readlink_f $2/$filename)
    else
        distfile=$(_gnu_readlink_f $2)
    fi

    # overwrite check
    if $(cmp -s $srcfile $distfile); then
    # same file
        print_information "skipped ${distfile}"
        return 0
    elif [[ -e $distfile ]]; then
    # distfile already exists
        print_warning "${distfile} saved as ${distfile}.dotnew"
        distfile=$distfile.dotnew
    fi

    print_information "installed in ${distfile}"
    install -m644 $srcfile $distfile
}

dotfile_install() {
    if [[ $# -ne 2 ]]; then
        return 1
    fi

    # destination file
    if ! [[ $1 == .* ]] && [[ -d $2 ]]; then
        # src is dotfile and dist is directory
        filename=$(basename $1)
        distfile=$(_gnu_readlink_f $2/.$filename)
    else
        # do nothing
        distfile=$2
    fi

    safe_install $1 $distfile
}
