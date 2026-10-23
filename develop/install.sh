#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../vendor/dotfiles-lib/dotfiles-lib.sh" || exit 1

k9s_dir=$HOME/.k9s
install -d "$k9s_dir"
dfl_safe_install "$script_dir/k9s.yml" "$k9s_dir/config.yml"

if dfl_installed docker-credential-ecr-login; then
    docker_dir=$HOME/.docker
    install -d "$docker_dir"
    dfl_safe_install "$script_dir/docker.json" "$docker_dir/config.json"
fi

dfl_install_all "$script_dir" k9s.yml docker.json
