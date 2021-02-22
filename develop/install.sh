#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../external/libshellscript/libshellscript/libshellscript.sh

k9s_dir=$HOME/.k9s
install -d $k9s_dir
safe_install $script_dir/k9s.yml $k9s_dir/config.yml

if installed docker-credential-ecr-login; then
    docker_dir=$HOME/.docker
    install -d $docker_dir
    safe_install $script_dir/docker.json $docker_dir/config.json
fi

install_all $script_dir k9s.yml docker.json
