#! /usr/bin/env bash

set -eEuo pipefail

print_error() {
  printf "\e[1;31m%s\e[0m\n" "${1}" >&2
}

REGEX="^(?<COMMIT_TYPE>feat|fix|perf|revert|docs|style|refactor|test|build|ci|chore)(?<SCOPE>\\((?<JIRA_BOARD>[A-Z]{3,})-(?<TICKET_NUMBER>[0-9]+)\\))?: (?<DESCRIPTION>[a-z0-9][a-zA-Z0-9 \\-_/().,#+]*[a-zA-Z0-9\\-_/(),#+])$"

usage() {
    cat << EOF
Usage : $0
    [ -m | --message <MESSAGE> ] - The change description to use (don't open editor)
    Other options are passed to jj describe
EOF
}

# getopt is a bashism
if ! args=$(getopt -o m: --longoptions message: -- "$@"); then
    print_error "Invalid option"
    usage >&2
    exit 1
fi

MESSAGE=""

eval set -- "${args}"
while :
do
    case $1 in
        -m | --message) MESSAGE="$2"    ; shift 2;;
        --) shift ; break ;;
        *) print_error "unsupported option: $1"; usage >&2; exit 1 ;;
    esac
done

OK="false"
TEMP_FILE="$(mktemp)"

if [ -z "${MESSAGE}" ]; then
    nvim "${TEMP_FILE}"
else
    printf "%s" "${MESSAGE}" > "${TEMP_FILE}"
fi
LINE_COUNT="$(wc -l "${TEMP_FILE}" | cut -f1 -d' ')"
LINE_1="$(head -n1 "${TEMP_FILE}")"
if [ "${LINE_COUNT}" -gt 1 ]; then
  LINE_2="$(head -n2 "${TEMP_FILE}" | tail -n1)"
    if [ "${LINE_COUNT}" -gt 2 ]; then
        LINE_3="$(head -n3 "${TEMP_FILE}" | tail -n1)"
        if [ -n "${LINE_3}" ]; then
            if [ ! -z "${LINE_2}" ]; then
                print_error "Line 2 must be blank if details are present"
                OK="false"
            else
                OK="true"
            fi
        fi
    else
        print_error "Multi-line commit messages must contain details"
        OK="false";
    fi
else
    LINE_2=""
    LINE_3=""
    OK="true"
fi

LINE_1_LENGTH="$(printf "%s" "${LINE_1}" | wc -m)"

if [ "${LINE_1_LENGTH}" -gt 50 ]; then
    print_error "Line 1 too long"
    OK="false"
fi

while IFS= read -r LINE; do
    if [ "$(printf "%s" "${LINE}" | wc -m)" -gt 99 ]; then
        OK="false"
        print_error "Line > 99 characters"
    fi
done < "${TEMP_FILE}"

if [ "${OK}" = "true" ] && head -n1 "${TEMP_FILE}" | rg --stop-on-nonmatch "$REGEX" >/dev/null; then
    OK="true"
else
    print_error "Title didn't match regex"
    OK="false"
fi

if [ "${OK}" = "false" ]; then
    print_error "Commit message did not comply with conventional commits format"
    rm "${TEMP_FILE}"
    exit 1
fi

jj describe --stdin "$@" <"${TEMP_FILE}"
rm "${TEMP_FILE}"
