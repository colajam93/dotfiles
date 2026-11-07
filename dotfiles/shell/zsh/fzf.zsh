# fzf shell integration requires fzf 0.48 or newer.
if (( $+commands[fzf] )); then
    () {
        local integration
        if integration=$(fzf --zsh); then
            eval "$integration"
            if (( $+widgets[fzf-cd-widget] )); then
                bindkey -M emacs '^O' fzf-cd-widget
                bindkey -M emacs '^[c' capitalize-word
            fi
        else
            print -u2 -- 'zsh: fzf shell integration requires fzf 0.48 or newer'
        fi
    }
fi
