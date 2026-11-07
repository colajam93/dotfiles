# Preserve existing history files and larger limits.
[[ -n $HISTFILE ]] || HISTFILE=$HOME/.zsh_history
(( HISTSIZE >= 50000 )) || HISTSIZE=50000
(( SAVEHIST >= 10000 )) || SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups
setopt hist_ignore_space hist_verify share_history
