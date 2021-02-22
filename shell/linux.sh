# SSH Agent
if [ -n "$DESKTOP_SESSION" ]; then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
else
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
fi
