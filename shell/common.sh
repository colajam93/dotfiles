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

if type "rlwrap" &> /dev/null; then
    alias sbcl='rlwrap sbcl'
    alias maxima='rlwrap maxima'
fi
if ls --help 2>&1 | egrep -q 'coreutils|BusyBox'; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
if grep --help 2>&1 | grep -q 'GNU grep'; then
    alias grep='grep --color=auto'
fi
if diff --help 2>&1 | grep -q 'diffutils'; then
    alias diff='diff --color=auto'
fi
alias tmux='tmux -2'

# environment variable
export EDITOR=vim
export SYSTEMD_EDITOR=$EDITOR
export GOPATH="$HOME/local/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.local/bin"

if type "virtualenvwrapper_lazy.sh" &> /dev/null; then
    export VIRTUALENVWRAPPER_PYTHON="$(which python3)"
    source $(which "virtualenvwrapper_lazy.sh")
fi

# load environment specific file
[[ -f ~/.shell/platform.sh ]] && . ~/.shell/platform.sh
[[ -f ~/.shell/private.sh ]] && . ~/.shell/private.sh
