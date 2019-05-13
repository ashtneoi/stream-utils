#!/usr/bin/env bash
set -eu

root="$(dirname "$0")"

cd "$root" && ./nginx -p $PWD -g "error_log error.log;" -c nginx-rtmp.conf "$@"
