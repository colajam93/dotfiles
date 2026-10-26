_dfl_overwrite_file() {
    local destfile_new=$1
    local destfile_old=$2
    mv -- "$destfile_new" "$destfile_old" || return 1
    dfl_print_information "mv $destfile_new $destfile_old"
}

_dfl_regex_is_valid() (
    # Keep shell option changes local to this subshell.
    set +e
    local status
    [[ '' =~ $1 ]]
    status=$?
    # Both a match (0) and no match (1) mean the syntax is valid.
    [[ $status -ne 2 ]]
)

_dfl_is_quiet() {
    [[ "${_dfl_quiet:-false}" == "true" ]]
    return $?
}

_dfl_print_message() {
    # tput setaf indices: 1=red, 2=green, 3=yellow, 4=blue.
    local color='' reset=''
    # Check the descriptor at the call site, including redirection to stderr.
    if [[ -t 1 && -n ${TERM:-} && ${TERM:-} != dumb ]] &&
       color=$(tput setaf "$1" 2>/dev/null) &&
       reset=$(tput sgr0 2>/dev/null); then
        printf '%s%s%s %s\n' "$color" "$2" "$reset" "$3"
    else
        printf '%s %s\n' "$2" "$3"
    fi
}

dfl_print_error() {
    _dfl_is_quiet && return 0
    _dfl_print_message 1 error: "$1"
}

dfl_print_warning() {
    _dfl_is_quiet && return 0
    _dfl_print_message 3 warning: "$1"
}

dfl_print_information() {
    _dfl_is_quiet && return 0
    _dfl_print_message 4 information: "$1"
}

_dfl_print_link() {
    local action=$1 destination=$2 source=$3 reason=${4:-} message color
    case $action in
        create) color=2 ;; # Green
        skip) color=4 ;; # Blue
        conflict) color=1 ;; # Red
        *) return 1 ;;
    esac
    printf -v message '%q -> %q' "$destination" "$source"
    if [[ -n $reason ]]; then
        message+=" ($reason)"
    fi
    _dfl_print_message "$color" "$action" "$message"
}

dfl_safe_install() {
    # source file
    if [[ -e $1 ]]; then
        local srcfile
        IFS= read -r -d '' srcfile < <(readlink -fz -- "$1") || return 1
    else
        echo "$1: No such file or directory"
        return 1
    fi

    # destination file
    local destfile
    if [[ -d $2 ]]; then
        local filename
        IFS= read -r -d '' filename < <(basename -z -- "$srcfile") || return 1
        IFS= read -r -d '' destfile < <(readlink -fz -- "$2/$filename") || return 1
    else
        IFS= read -r -d '' destfile < <(readlink -fz -- "$2") || return 1
    fi

    # if argc == 3, use 3rd argument as permission mode which pass to install -m
    local permission='644'
    if [[ $# -eq 3 ]]; then
        permission=$3
    fi

    local destfile_old='' destfile_new=''

    # overwrite check
    # same file
    if cmp -s -- "$srcfile" "$destfile"; then
        dfl_print_information "skipped ${destfile}"
        return 0
    # destfile already exists
    elif [[ -e $destfile ]]; then
        destfile_old=$destfile
        destfile_new=$destfile.dotnew
        destfile=$destfile_new
        dfl_print_warning "${destfile_old} saved as ${destfile}"
    fi

    install -m "$permission" -- "$srcfile" "$destfile" || return 1
    dfl_print_information "installed in ${destfile}"

    if [[ $destfile_new != "" ]]; then
        if [[ "${_dfl_force:-false}" == "true" ]]; then
            _dfl_overwrite_file "$destfile_new" "$destfile_old"
        else
            local diff_status=0
            diff --color=auto -u -- "$destfile_old" "$destfile_new" >&2 || diff_status=$?
            [[ $diff_status -le 1 ]] || return 1
            printf 'overwrite %s by new file? [y/N] ' "$destfile_old" >&2 || return 1
            local input
            if ! read -r input; then
                printf '\n' >&2 || return 1
                return 0
            fi
            if [[ $input == "y" ]]; then
                _dfl_overwrite_file "$destfile_new" "$destfile_old"
            fi
        fi
    fi
}

dfl_dotfile_install() {
    if [[ $# -ne 2 ]]; then
        return 1
    fi

    # destination file
    local destfile
    # src is not dotfile and dest is directory
    if ! [[ $1 == .* ]] && [[ -d $2 ]]; then
        local filename
        IFS= read -r -d '' filename < <(basename -z -- "$1") || return 1
        IFS= read -r -d '' destfile < <(readlink -fz -- "$2/.$filename") || return 1
    # do nothing
    else
        destfile=$2
    fi

    dfl_safe_install "$1" "$destfile"
}

dfl_install_all() {
    local target_dir=$1
    shift
    [[ -d $target_dir ]] || return 1
    local patterns=()
    local pattern regex
    for pattern in 'install.sh' '.*.swp' "$@"; do
        # Preserve the existing ERE matching against the source path.
        regex="${pattern}$"
        _dfl_regex_is_valid "$regex" || return 1
        patterns+=("$regex")
    done

    local files=() find_pid
    mapfile -d '' -t files < <(find "$target_dir" -maxdepth 1 -type f -print0) || return 1
    find_pid=$!
    # Check the producer before applying an incomplete listing.
    wait "$find_pid" || return 1

    local i srcfile
    for i in "${files[@]}"; do
        for regex in "${patterns[@]}"; do
            if [[ $i =~ $regex ]]; then
                continue 2
            fi
        done
        IFS= read -r -d '' srcfile < <(readlink -fz -- "$i") || return 1
        dfl_dotfile_install "$srcfile" "$HOME" || return 1
    done
}

dfl_platform_name() {
    local n
    n=$(uname -s) || return 1
    if [[ $n == "Linux" ]]; then
        echo "linux"
    elif [[ $n == "Darwin" ]]; then
        echo "mac"
    else
        echo "$n"
    fi
}

dfl_installed() {
    type "$1" &> /dev/null
    return $?
}

# A plan spans all selected categories in the current shell.
_dfl_link_sources=()
_dfl_link_destinations=()

dfl_link_reset() {
    _dfl_link_sources=()
    _dfl_link_destinations=()
}

dfl_link_add() {
    if [[ $# -ne 2 || -z $1 || -z $2 ]]; then
        dfl_print_error 'usage: dfl_link_add SOURCE DESTINATION' >&2
        return 1
    fi
    local source=$1 destination=$2
    [[ $source == /* ]] || source=$PWD/$source
    [[ $destination == /* ]] || destination=$PWD/$destination
    _dfl_link_sources+=("$source")
    _dfl_link_destinations+=("$destination")
}

# Resolve only the parent: the destination itself may be a conflicting link.
# NUL-delimited output preserves paths ending in a newline.
_dfl_link_destination() {
    local destination=$1 parent ancestor name
    name=${destination##*/}
    if [[ -z $name || $name == . || $name == .. ]]; then
        return 1
    fi
    parent=${destination%/*}
    parent=${parent:-/}
    ancestor=$parent
    while [[ ! -e $ancestor && ! -L $ancestor ]]; do
        ancestor=${ancestor%/*}
        ancestor=${ancestor:-/}
    done
    [[ -d $ancestor ]] || return 1
    IFS= read -r -d '' parent < <(realpath -zm -- "$parent") || return 1
    printf '%s\0' "${parent%/}/$name"
}

_dfl_link_matches() {
    local source destination
    [[ -L $2 ]] || return 1
    IFS= read -r -d '' source < <(realpath -ze -- "$1") || return 1
    IFS= read -r -d '' destination < <(realpath -ze -- "$2") || return 1
    [[ $source == "$destination" ]]
}

dfl_link_check() {
    local i j source destination previous directory
    local destinations=() directories=()
    for i in "${!_dfl_link_sources[@]}"; do
        source=${_dfl_link_sources[i]}
        if [[ ! -e $source ]]; then
            dfl_print_error "link source does not exist: $source" >&2
            return 1
        fi
        if ! IFS= read -r -d '' destination < <(
            _dfl_link_destination "${_dfl_link_destinations[i]}"
        ); then
            dfl_print_error "invalid link destination: ${_dfl_link_destinations[i]}" >&2
            return 1
        fi
        directory=$destination
        if [[ -L $destination && -d $destination ]]; then
            IFS= read -r -d '' directory < <(realpath -ze -- "$destination") || return 1
        fi
        for j in "${!destinations[@]}"; do
            previous=${destinations[j]}
            if [[ $destination == "$previous" ||
                  $destination == "${directories[j]%/}/"* ||
                  $previous == "${directory%/}/"* ]]; then
                dfl_print_error "overlapping link destinations: $previous and $destination" >&2
                return 1
            fi
        done
        destinations+=("$destination")
        directories+=("$directory")
        if _dfl_link_matches "$source" "$destination"; then
            continue
        fi
        if [[ -e $destination || -L $destination ]]; then
            dfl_print_error "link destination already exists: $destination" >&2
            return 1
        fi
    done
}

dfl_link_preview() {
    local i j source destination directory action reason
    local status=0
    local destinations=() directories=()

    # Report each entry once; overlaps are reported on the later entry.
    for i in "${!_dfl_link_sources[@]}"; do
        source=${_dfl_link_sources[i]}
        destination=${_dfl_link_destinations[i]}
        reason=
        if [[ ! -e $source ]]; then
            reason='source does not exist'
        elif ! IFS= read -r -d '' directory < <(_dfl_link_destination "$destination"); then
            reason='invalid destination'
        else
            destination=$directory
            if [[ -L $destination && -d $destination ]]; then
                IFS= read -r -d '' directory < <(realpath -ze -- "$destination") || return 1
            fi
            for j in "${!destinations[@]}"; do
                if [[ $destination == "${destinations[j]}" ||
                      $destination == "${directories[j]%/}/"* ||
                      ${destinations[j]} == "${directory%/}/"* ]]; then
                    reason='overlapping destinations'
                    break
                fi
            done
            destinations+=("$destination")
            directories+=("$directory")
            if [[ -z $reason ]] && ! _dfl_link_matches "$source" "$destination" &&
               [[ -e $destination || -L $destination ]]; then
                reason='destination already exists'
            fi
        fi

        if [[ -n $reason ]]; then
            _dfl_print_link conflict "$destination" "$source" "$reason" || return 1
            status=1
            continue
        fi
        action=create
        if _dfl_link_matches "$source" "$destination"; then
            action=skip
        fi
        _dfl_print_link "$action" "$destination" "$source" || return 1
    done
    return "$status"
}


dfl_link_apply() {
    dfl_link_check || return 1
    local i source destination action
    for i in "${!_dfl_link_sources[@]}"; do
        source=${_dfl_link_sources[i]}
        IFS= read -r -d '' destination < <(
            _dfl_link_destination "${_dfl_link_destinations[i]}"
        ) || return 1
        if _dfl_link_matches "$source" "$destination"; then
            action=skip
        else
            mkdir -p -- "${destination%/*}/" || return 1
            ln -sT -- "$source" "$destination" || return 1
            action=create
        fi
        if ! _dfl_is_quiet; then
            _dfl_print_link "$action" "$destination" "$source" || return 1
        fi
    done
}
