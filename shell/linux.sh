# internal functions

_sc_keychain_init() {
    if [[ -z ${SSH_AGENT_PID+x} ]]; then
        eval $(keychain --eval --quiet)
    fi
}

_sc_confpath() {
    local i
    for i in ~/.ssh/config ~/.ssh/conf.d/*; do
        if [[ -f $i ]]; then
            _sc_confpath_file $1 < "$i"
        fi
    done
}

_sc_confpath_file() {
    local h=""
    while IFS= read -r line; do
        # get the Host directives
        case $line in
            *"Host "*) h=$(echo $line | awk '{print $2}') ;;
        esac
        case $line in
            *IdentityFile*)
                if [ $h = "$1" ]; then
                    local var=$(echo $line | awk '{print $2}')
                    # expand '~'
                    echo "${var/#\~/$HOME}"
                    break
                fi
        esac
    done
}

# exported functions

key-add() {
    local hosts=$(for i in $@; do _sc_confpath $i; done)
    if type "keychain" &> /dev/null; then
        _sc_keychain_init
        keychain --confhost ${hosts[@]}
    else
        ssh-add ${hosts[@]}
    fi
}

# main

if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

if type "keychain" &> /dev/null; then
   _sc_keychain_init
fi
