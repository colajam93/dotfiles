from i3pystatus import Status

status = Status(standalone=True)

# Displays clock
status.register("clock",
                format="%Y-%m-%d(%a) %H:%M:%S")

# Displays master volume
status.register("pulseaudio",
                format="♪:{volume}%",
                color_muted="#AAAAAA",
                )

# Displays speaker state
status.register("alsa",
                format="♪SPEAKER",
                format_muted="",
                mixer="Speaker",
                color="#FF0000",
                card=1)

# Displays battery
status.register("battery",
                format="{status}:{percentage:.2f}%",
                alert_percentage=5,
                status={
                    "DPL": "DPL",
                    "DIS": "↓",
                    "CHR": "↑",
                    "FULL": "=",
                })

# Displays VPN status
status.register("openvpn",
                format='{status}',
                vpn_name="client",
                status_command="bash -c 'systemctl show openvpn-client@%(vpn_name)s | grep ActiveState=active'",
                status_up='VPN',
                status_down='')

# netctl-auto profile
command = r'r=$(netctl-auto list | grep "*" | cut -d " " -f 2); [[ $r == "" ]] ' \
          r'&& echo "<span></span>" ' \
          r'|| echo "<span color=\"#00FF00\">@$r</span>"'
status.register('shell',
                command=command,
                hints={'markup': 'pango'})

# Displays wifi status
status.register("network",
                interface="wlp3s0",
                format_up="WL:{v4cidr}",
                format_down="WL:DOWN",
                hints={"separator": False, "separator_block_width": 0})

# Ethernet
status.register('network',
                interface='ens9',
                format_up='ETHERNET:{v4cidr}',
                format_down='',
                interval=5)

# Memory usage
status.register('mem',
                format='MEM:{percent_used_mem}%',
                warn_percentage=60,
                color='#FFFFFF')

# Displays disk usage
status.register("disk",
                path="/",
                interval=300,
                format="DISK:{avail}GB")

# NowPlaying
status.register('now_playing',
                format='{status}:{title}/{artist}',
                status={'play': '<span color="#00FF00">▶</span>', 'pause': '■', 'stop': '■'},
                hints={'markup': 'pango'})

status.run()
