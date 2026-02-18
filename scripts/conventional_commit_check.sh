#! /usr/bin/env bash

print_error() {
  printf "\e[1;31m%s\e[0m\n" "${1}" >&2
}

REGEX="^(?<COMMIT_TYPE>feat|fix|perf|revert|docs|style|refactor|test|build|ci|chore)(?<SCOPE>\((?<JIRA_BOARD>[A-Z]+)-(?<TICKET_NUMBER>[0-9]+)\))?!?: (?<DESCRIPTION>.+)"


OK="false"
TEMP_FILE="$(mktemp)"
nvim "${TEMP_FILE}"
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

if [ "${OK}" = "true" ] && head -n1 "${TEMP_FILE}" | rg --ignore-case --stop-on-nonmatch "$REGEX" >/dev/null; then
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
