#! /usr/bin/env bash

set -eEuo pipefail

WORKING_DIR="$(pwd)"
TEMP_FILE="$(mktemp)"
printf "%s" "${WORKING_DIR}">"${TEMP_FILE}"
if rg "\/home\/carl\/code\/KeepTruckin\/kt" "${TEMP_FILE}" >/dev/null; then
  uvx --with pre-commit jj-pre-push --checker "/home/carl/.config/home-manager/scripts/prek_ktmr.sh" check
else
  uvx --with pre-commit jj-pre-push --checker prek check
fi

if [ "The working copy has no changes." = "$(jj st | head -n1)" ]; then
  echo "Error, empty commit. Check pre-commit results."
  exit 1
fi

/home/carl/.config/home-manager/scripts/conventional_commit_check.sh "$@"
jj new
