#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "./logos/1password.png" -s "1password" -n "1Password" -u "https://my.1password.com" "$@"
