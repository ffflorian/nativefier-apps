#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "threema.png" -s "threema" -n "Threema" -u "web.threema.ch" "$@"
