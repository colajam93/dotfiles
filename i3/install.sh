#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

if [[ $(platform_name) != "linux" ]]; then
    print_error "platform is not Linux"
    exit 1
fi

i3_dir=$HOME/.i3
install -d $i3_dir
safe_install $script_dir/config $i3_dir
safe_install $script_dir/i3pystatus_config.py $i3_dir

print_information "Prepare virtualenv for i3"
source $(which virtualenvwrapper.sh)
if ! lsvirtualenv -b | grep i3 > /dev/null 2>&1; then
    mkvirtualenv i3
else
    workon i3
fi
print_information "Install i3 dependencies"
pip install --upgrade -r "${script_dir}/requirements.txt"
