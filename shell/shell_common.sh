# function
_sc_pyenv_exec() {
    source $HOME/.virtualenvs/default/bin/activate
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
    alias "$1=_sc_pyenv_exec $1"
}

_sc_pyenv_alias yapf

unset -f _sc_pyenv_alias

# rlwrap
_sc_rlwrap_alias() {
    alias "$1=rlwrap $1"
}

_sc_rlwrap_alias sbcl
_sc_rlwrap_alias maxima

unset -f _sc_rlwrap_alias


if ls --version 2> /dev/null | grep -q 'coreutils'; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias tmux='tmux -2'

# environment variable
export EDITOR=vim
export SYSTEMD_EDITOR=$EDITOR
COCOS=$HOME/local/cocos2d-x/tools/cocos2d-console/bin
export GOPATH=$HOME/local/go
export PATH=$HOME/.local/bin:$PATH:$COCOS:$GOPATH/bin

if [[ -f /usr/bin/virtualenvwrapper_lazy.sh ]]; then
    source /usr/bin/virtualenvwrapper_lazy.sh
fi
