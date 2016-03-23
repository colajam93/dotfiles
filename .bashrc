#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias tmux='tmux -2'
alias sbcl='rlwrap sbcl'
PS1='[\u@\h \W]\$ '
export EDITOR=vim
export SYSTEMD_EDITOR=$EDITOR
complete -cf sudo
complete -cf man
export COCOS_CONSOLE_ROOT=$HOME/local/cocos2d-x/tools/cocos2d-console/bin
export GOPATH=$HOME/local/go
export PATH=$HOME/.local/bin:$PATH:$COCOS_CONSOLE_ROOT:$GOPATH/bin

source $HOME/.shell_common.sh

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
