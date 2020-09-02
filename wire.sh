#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "./logos/wire.png" -s "wire" -n "Wire" -u "https://app.wire.com" "$@"
