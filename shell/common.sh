# Functions
man() {
    LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    command man "$@"
}

certinfo() {
    if [ "$#" -ne 1 ]; then
            echo "usage: certinfo [DOMAIN]"
            return
    fi
    echo | openssl s_client -showcerts -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -text
}

random_string() {
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c $1 ; echo ''
}

# Aliases
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

# User binary path
export PATH="$PATH:$HOME/.local/bin"

# Editor
export EDITOR=vim
export SYSTEMD_EDITOR=$EDITOR

# Python
export PIPENV_VENV_IN_PROJECT=1

# Dcoker
export DOCKER_BUILDKIT=1

# asdf
if [[ -e "$HOME/.asdf/asdf.sh" ]]; then
    . $HOME/.asdf/asdf.sh
fi

# ghq (depends to asdf)
export GHQ_ROOT=$HOME/work/ghq
if command -v ghq &> /dev/null; then
    alias ghq-cd='p=$(ghq list | fzf) && cd "$(ghq root)/$p"'
fi

# cargo
if [[ -e "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# .NET SDK
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Load environment specific config
[[ -f ~/.shell/platform.sh ]] && . ~/.shell/platform.sh
[[ -f ~/.shell/private.sh ]] && . ~/.shell/private.sh
