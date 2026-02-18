#! /usr/bin/env bash

set -e

/home/carl/.config/home-manager/scripts/conventional_commit_check.sh "$@"
jj new
