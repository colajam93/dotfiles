#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
image="dotfiles-lib-tests:ubuntu-26.04"

docker build --tag "$image" - < "$script_dir/docker/Dockerfile"
docker run --rm \
    --network none \
    --user "$(id -u):$(id -g)" \
    --mount "type=bind,src=$repo_dir,dst=/workspace,readonly" \
    --entrypoint bash \
    "$image" -c 'shellcheck --shell=bash \
        /workspace/dotfiles-lib.sh \
        /workspace/tests/*.sh \
        /workspace/tests/docker/*.sh \
        /workspace/tests/cases/*.sh'
