#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

# keychain
if [[ $(platform_name) == "linux" ]] && ! installed 'keychain'; then
    keychain_latest_api='https://api.github.com/repos/funtoo/keychain/releases/latest'
    print_information "getting metadata of keychain"
    keychain_latest_url=$(curl -s $keychain_latest_api | grep zipball_url | cut -d '"' -f 4)
    temp_dir=$(mktemp -d)
    zip_path="$temp_dir/keychain.zip"
    print_information "downloading keychain"
    curl -s -L -o $zip_path $keychain_latest_url
    print_information "unpacking keychain"
    unzip -q -d $temp_dir $zip_path
    keychain_src_dir=$(find $temp_dir -type d -maxdepth 1 -mindepth 1)
    print_information "installing keychain"
    safe_install "$keychain_src_dir/keychain" $HOME/.local/bin 755
fi
