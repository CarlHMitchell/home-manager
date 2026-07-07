#!/usr/bin/env bash

set -eEuo pipefail

MESSAGE_FILE="$(mktemp)"

trap cleanup EXIT

cleanup()
{
    if [ -f "${MESSAGE_FILE}" ]; then
      rm "${MESSAGE_FILE}"
    fi
}

COMMIT_ID="$(jj log -r @ --no-graph -T "self.commit_id()")"

npx commitlint --verbose --from="${COMMIT_ID}^" --to="${COMMIT_ID}" 1>&2
