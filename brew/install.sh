#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

if [[ $(platform_name) != "mac" ]]; then
    print_error "platform is not MacOS"
    exit 1
fi

if ! installed "brew"; then
    print_error "brew is not installed"
    exit 1
fi

print_information "Update HomeBrew"
brew update
brew upgrade
brew install \
    bash \
    clang-format \
    cmake \
    coreutils \
    diffutils \
    findutils \
    git \
    gnu-sed \
    grep \
    macvim \
    nkf \
    python \
    python3 \
    rlwrap \
    tig \
    tmux \
    vim \
    zsh
