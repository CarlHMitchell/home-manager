#! /usr/bin/env bash

set -eEuo pipefail

TEMP_FILE="$(mktemp)"
cleanup() {
    if [ -f "${TEMP_FILE}" ]; then
        rm -f "${TEMP_FILE}"
    fi
}
trap "cleanup" EXIT

print_error() {
  local fmt="$1"; shift
  local msg
  # I *want* the caller to control the format here.
  # shellcheck disable=SC2059
  printf -v msg "${fmt}" "$@"
  printf "\e[1;31m%s\e[0m\n" "${msg}" >&2
}

print_warning() {
  local fmt="$1"; shift
  local msg
  # I *want* the caller to control the format here.
  # shellcheck disable=SC2059
  printf -v msg "${fmt}" "$@"
  printf "\e[1;33m%s\e[0m\n" "${msg}" >&2
}

REGEX="^(?<COMMIT_TYPE>feat|fix|perf|revert|docs|style|refactor|test|build|ci|chore)(?<SCOPE>\\((?<JIRA_BOARD>[A-Z]{3,})-(?<TICKET_NUMBER>[0-9]+)\\))?: (?<DESCRIPTION>[a-z0-9][a-zA-Z0-9 \\-_/().,#+]*[a-zA-Z0-9\\-_/(),#+])$"

usage() {
    cat << EOF
Usage : $0
    [ -m | --message <MESSAGE> ] - The change description to use.
    [] -r | --revisions <revset> ] - The revset(s) to describe, defaults to @.
    Other options are passed to jj describe
EOF
}

# getopt is a bashism
if ! args=$(getopt -o m:r: --longoptions message:,revisions: -- "$@"); then
    print_error "Invalid option"
    usage >&2
    exit 1
fi

MESSAGE=""
REVISIONS=""

eval set -- "${args}"
while :
do
    case $1 in
        -m | --message)   MESSAGE="$2"    ; shift 2;;
        -r | --revisions) REVISIONS="$2"  ; shift 2;;
        --)                                 shift ; break ;;
        *)  print_error "Unrecognized option $1"; exit 1;
    esac
done

if [ -z "${REVISIONS}" ]; then
    REVISIONS="@"
fi

OK="false"

jj show -r "${REVISIONS}" -s >"${TEMP_FILE}"
echo "Lines starting with \"JJ:\" (like this one) will be removed." >>"${TEMP_FILE}"
sed -i 's/^/JJ: /' "${TEMP_FILE}"
sed -i '1s;^;\n\n;' "${TEMP_FILE}"

if [ -z "${MESSAGE}" ]; then
    nvim "${TEMP_FILE}"
    sed -i '/^JJ: /d' "${TEMP_FILE}"
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
    print_warning "Line 1 will truncate in GitHub's output"
fi

while IFS= read -r LINE; do
    if [ "$(printf "%s" "${LINE}" | wc -m)" -gt 99 ]; then
        OK="false"
        print_error "Line ${LINE} > 99 characters"
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
    print_error "Message provided:\n%s\n" "$(cat "${TEMP_FILE}")"
    exit 1
fi

REVISION_ARGS=()
[ -n "${REVISIONS}" ] && REVISION_ARGS=(-r "${REVISIONS}")
jj describe --stdin "${REVISION_ARGS[@]}" "$@" <"${TEMP_FILE}"
