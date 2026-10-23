#!/usr/bin/env bash
set -e

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export SHUNIT2="${SHUNIT2:-/usr/share/shunit2/shunit2}"

if [[ ! -r "$SHUNIT2" ]]; then
    printf 'shUnit2 not found: %s\nRun ./tests/run.sh or set SHUNIT2.\n' "$SHUNIT2" >&2
    exit 1
fi

for test_file in "$script_dir"/../cases/test_*.sh; do
    bash "$test_file"
done
