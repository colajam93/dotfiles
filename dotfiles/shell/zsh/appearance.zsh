# ls aliases are defined by common.sh. Only initialize its palette here.
if [[ -z $LS_COLORS ]]; then
    if (( $+commands[dircolors] )); then
        if [[ -f $HOME/.dircolors ]]; then
            eval "$(dircolors -b "$HOME/.dircolors" 2>/dev/null || dircolors -b)"
        else
            eval "$(dircolors -b)"
        fi
    else
        export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
    fi
fi
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
