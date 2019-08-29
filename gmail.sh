#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "gmail.png" -s "gmail" -n "Google Mail" -u "mail.google.com" "$@"
