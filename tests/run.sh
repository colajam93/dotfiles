#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
image="dotfiles-tests:ubuntu-26.04"

docker build --tag "$image" - < "$repo_dir/vendor/dotfiles-lib/tests/docker/Dockerfile"
docker run --rm \
    --network none \
    --user "$(id -u):$(id -g)" \
    --mount "type=bind,src=$repo_dir,dst=/workspace,readonly" \
    --entrypoint bash \
    "$image" -ec 'for test_file in /workspace/tests/cases/test_*.sh; do
        bash "$test_file"
    done'
