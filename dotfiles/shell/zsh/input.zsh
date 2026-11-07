bindkey -e
WORDCHARS=''
zmodload zsh/terminfo

# Preserve the terminal's application-mode key sequences without replacing hooks.
autoload -Uz add-zle-hook-widget
if [[ -n ${terminfo[smkx]} && -n ${terminfo[rmkx]} ]]; then
    _dotfiles_keypad_on() { echoti smkx }
    _dotfiles_keypad_off() { echoti rmkx }
    add-zle-hook-widget line-init _dotfiles_keypad_on
    add-zle-hook-widget line-finish _dotfiles_keypad_off
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char
bindkey '^[[3;5~' kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^?' backward-delete-char
bindkey ' ' magic-space

() {
    local capability widget
    for capability widget in \
        kpp up-line-or-history knp down-line-or-history \
        kcuu1 up-line-or-beginning-search kcud1 down-line-or-beginning-search \
        khome beginning-of-line kend end-of-line \
        kcbt reverse-menu-complete kdch1 delete-char; do
        [[ -z ${terminfo[$capability]} ]] || bindkey "${terminfo[$capability]}" "$widget"
    done
}

autoload -Uz edit-command-line url-quote-magic
zle -N edit-command-line
bindkey '^X^E' edit-command-line
# Protect manually typed URLs; keep zsh's builtin bracketed paste unchanged.
zle -N self-insert url-quote-magic
