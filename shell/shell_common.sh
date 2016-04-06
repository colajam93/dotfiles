# function
_sc_pyenv_exec() {
    source $HOME/.local/lib/python/bin/activate
    $@
    deactivate
}

man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
        LESS_TERMCAP_md=$'\E[01;38;5;74m' \
        LESS_TERMCAP_me=$'\E[0m' \
        LESS_TERMCAP_se=$'\E[0m' \
        LESS_TERMCAP_so=$'\E[38;5;246m' \
        LESS_TERMCAP_ue=$'\E[0m' \
        LESS_TERMCAP_us=$'\E[04;38;5;146m' \
        man "$@"
}

certinfo() {
    if [ "$#" -ne 1 ]; then
            echo "usage: certinfo [DOMAIN]"
            return
    fi
    echo | openssl s_client -showcerts -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -text
}

docker-cleanup() {
    processes=$(docker ps -q -f status=exited)
    if [ -n "$processes" ]; then
      docker rm $processes
    fi
    
    images=$(docker images -q -f dangling=true)
    if [ -n "$images" ]; then
      docker rmi $images
    fi
}

# alias
# pyenv
_sc_pyenv_alias() {
    alias $1='_sc_pyenv_exec '$1
}

_sc_pyenv_alias yapf

unset -f _sc_pyenv_alias

# rlwrap
_sc_rlwrap_alias() {
    alias $1='rlwrap '$1
}

_sc_rlwrap_alias sbcl

unset -f _sc_rlwrap_alias
