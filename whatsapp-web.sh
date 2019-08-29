#!/usr/bin/env bash

set -e

# cd to script dir
cd "${0%/*}" || exit 1

./nativefier.sh -l "whatsapp.png" -s "whatsapp" -n "WhatsApp" -u "web.whatsapp.com" "$@"
