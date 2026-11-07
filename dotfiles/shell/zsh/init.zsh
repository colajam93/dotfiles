# Defaults first; common/platform/private settings may override them.
# Add shell behavior to the matching module, and completion generators to
# ../bin/update-zsh-completions.sh. Keep external tool initialization below.
for _dotfiles_module in history options input appearance completion terminal; do
    source "$HOME/.shell/zsh/$_dotfiles_module.zsh"
done
unset _dotfiles_module

source "$HOME/.shell/common.sh"

# Activate tools before registering integrations that depend on their PATH.
if [[ -x $HOME/.local/bin/mise ]]; then
    eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

# AWS's official completion uses zsh's builtin Bash compatibility layer.
if (( $+commands[aws_completer] )); then
    autoload -Uz bashcompinit
    bashcompinit
    complete -C aws_completer aws
fi

source "$HOME/.shell/zsh/fzf.zsh"

_ghq-cd() {
    ghq-cd
    zle reset-prompt
}
zle -N _ghq-cd
bindkey '^]' _ghq-cd

PROMPT='%m [%D{%H:%M:%S}] %1~ %# '
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi
