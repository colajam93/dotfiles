# function

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

docker_cleanup() {
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
export GOPATH="$HOME/local/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.local/bin"

vewl="virtualenvwrapper_lazy.sh"
if type $vewl > /dev/null 2>&1; then
    source $(which $vewl)
fi

# load environment specific file
[[ -f ~/.shell/platform.sh ]] && . ~/.shell/platform.sh
[[ -f ~/.shell/private.sh ]] && . ~/.shell/private.sh