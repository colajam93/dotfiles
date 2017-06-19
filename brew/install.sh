#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

if ! installed "brew"; then
    print_error "brew is not installed"
    exit 1
fi

brew install \
    bash \
    clang-format \
    cmake \
    coreutils \
    diffutils \
    git \
    gnu-sed \
    grep \
    macvim \
    nkf \
    python \
    python3 \
    rlwrap \
    tig \
    vim \
    zsh
