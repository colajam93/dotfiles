#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

i3_dir=$HOME/.i3
install -d $i3_dir
safe_install $script_dir/config $i3_dir
safe_install $script_dir/i3pystatus_config.py $i3_dir

source $(which virtualenvwrapper.sh)
if ! lsvirtualenv -b | grep i3 > /dev/null 2>&1; then
    mkvirtualenv i3
else
    workon i3
fi
pip install i3pystatus netifaces pyalsaaudio colour dbus-python psutil
