#!/usr/bin/env bash
# test.sh - Print the contents of the two exercise files.

# Stop on command errors, unset variables, and failed pipeline stages.
set -euo pipefail

# Resolve the files relative to this script, so it works from any directory.
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

cat -- "$script_dir/1.txt"
cat -- "$script_dir/2.txt"
