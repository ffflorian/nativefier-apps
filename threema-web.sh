#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "./logos/threema.png" -s "threema" -n "Threema" -u "https://web.threema.ch" "$@"
