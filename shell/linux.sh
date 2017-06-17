keychain-init() {
    eval $(keychain --eval --quiet)
}

keychain-add() {
    keychain-init
    local hosts=$(for i in $@; do _sc_confpath $i; done)
    keychain --confhost ${hosts[@]}
}

# get ssh key path from '~/.ssh/config'
_sc_confpath() {
    h=""
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
    done < ~/.ssh/config
}

_sc_keychain_init() {
    if [[ -z ${SSH_AGENT_PID+x} ]]; then
        keychain-init
    fi
}

_sc_ssh() {
    _sc_keychain_init
    ssh $@
}

_sc_scp() {
    _sc_keychain_init
    scp $@
}

_sc_rsync() {
    _sc_keychain_init
    rsync $@
}

if type "keychain" &> /dev/null; then
    alias ssh=_sc_ssh
    alias scp=_sc_scp
    alias rsync=_sc_rsync
fi
