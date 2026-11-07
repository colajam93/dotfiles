# Completion preferences retained from Oh My Zsh; see dotfiles/shell/OMZ-LICENSE.txt in this repository.
zmodload zsh/complist
unsetopt menu_complete
setopt auto_menu complete_in_word always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle '*' single-ignored show

# User names excluded from completion.
zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
    clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
    gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
    ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
    operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
    usbmux uucp vcsa wwwrun xfs '_*'

() {
    local data_home=${XDG_DATA_HOME:-$HOME/.local/share}
    local cache_home=${XDG_CACHE_HOME:-$HOME/.cache}
    [[ $data_home == /* ]] || data_home=$HOME/.local/share
    [[ $cache_home == /* ]] || cache_home=$HOME/.cache
    fpath=("$data_home/zsh/site-functions" $fpath)

    local cache_dir=$cache_home/zsh
    if [[ ! -d $cache_dir ]]; then
        (umask 077; mkdir -p -- "$cache_dir") || return 1
    fi
    zstyle ':completion:*' use-cache yes
    zstyle ':completion:*' cache-path "$cache_dir/completions"

    autoload -Uz compaudit compinit
    local insecure
    if ! insecure=$(compaudit 2>/dev/null); then
        print -u2 -r -- "zsh: excluding insecure completion paths:" "$insecure"
    fi
    # Keep security checks on every startup, even when a dump exists.
    compinit -i -d "$cache_dir/zcompdump-$ZSH_VERSION"
}
