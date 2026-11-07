setopt auto_cd auto_pushd pushd_ignore_dups
setopt long_list_jobs interactivecomments
unsetopt flowcontrol

alias ll='ls -lh'
alias la='ls -lAh'

# Respect exported values, including an explicitly empty value.
if (( $+commands[less] )); then
    [[ ${parameters[PAGER]} == *export* ]] || export PAGER=less
    [[ ${parameters[LESS]} == *export* ]] || export LESS=-R
elif (( $+commands[more] )); then
    [[ ${parameters[PAGER]} == *export* ]] || export PAGER=more
fi
