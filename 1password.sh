#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "1password.png" -s "1password" -n "1Password" -u "my.1password.com" "$@"
