#! /usr/bin/env bash

set -eEuo pipefail

/home/carl/.config/home-manager/scripts/conventional_commit_check.sh "$@"
jj new
