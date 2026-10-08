# shellcheck shell=bash
# Format the selected commits, then run `jj <subcmd> <subsubcmd> ...` (e.g. `git push`, `gerrit upload`).
# Formatters are resolved from PATH so project environments (direnv/nix) take precedence.
set -eEuo pipefail
if [ "$#" -lt 2 ]; then
  echo "usage: jj-format-and-run <jj subcommand> <jj subsubcommand> [args...]" >&2
  exit 1
fi
SUBCMD=("$1" "$2")
shift 2
# `jj git push` spells it --revisions, `jj gerrit upload` --revision
REV_FLAG=--revisions
[ "${SUBCMD[0]}" = gerrit ] && REV_FLAG=--revision
SKIP_FORMAT=0
PASS=()
PARTS=()

add_selector() {
  local flag="$1" value="$2" ids id pat
  case "${flag}" in
    -c | --change | -r | --revisions)
      ids="$(jj log -r "${value}" --no-graph -T 'change_id ++ " "')"
      if [ -z "${ids}" ]; then
        echo "Revset ${value} matched nothing" >&2
        exit 1
      fi
      for id in ${ids}; do
        case "${flag}" in
          -c | --change) PASS+=(--change "$id"); PARTS+=("(trunk()..$id)");;
          *) PASS+=("${REV_FLAG}" "$id"); PARTS+=("$id");;
        esac
      done;;
    -b | --bookmark)
      PASS+=(--bookmark "${value}")
      pat="${value}"
      case "$pat" in *:*) ;; *) pat="glob:$pat";; esac
      PARTS+=("bookmarks('$pat')");;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-format) SKIP_FORMAT=1; shift;;
    -c | --change | -r | --revisions | -b | --bookmark)
      if [ $# -lt 2 ]; then echo "$1 requires a value" >&2; exit 1; fi
      add_selector "$1" "$2"; shift 2;;
    --change=* | --revisions=* | --bookmark=*)
      add_selector "${1%%=*}" "${1#*=}"; shift;;
    -c?* | -r?* | -b?*)
      add_selector "${1:0:2}" "${1:2}"; shift;;
    *) PASS+=("$1"); shift;;
  esac
done

if [ "${#PARTS[@]}" -eq 0 ]; then
  echo "No -c/-r/-b given, running without formatting" >&2
  exec jj "${SUBCMD[@]}" "${PASS[@]}"
fi

if [ "0" = "${SKIP_FORMAT}" ]; then
  union="$(IFS='|'; echo "${PARTS[*]}")"
  TARGETS="$(jj log -r "(${union}) & mutable()" --reversed --no-graph -T 'change_id ++ " "')"
  START="$(jj log -r @ --no-graph -T 'change_id')"
  PARENTS="$(jj log -r '@-' --no-graph -T 'change_id ++ " "')"
  RESTORED=0
  restore() {
    if [ "${RESTORED}" = 1 ]; then return; fi
    RESTORED=1
    if jj log -r "${START}" --no-graph -T 'change_id' > /dev/null 2>&1; then
      jj edit "${START}"
    else
      # shellcheck disable=SC2086 # intentional word splitting
      jj new ${PARENTS}
    fi
  }
  trap restore EXIT

  run_fmt() {
    local pat="$1"
    shift
    { printf '%s\n' "${FILES}" | grep -E "${pat}" || true; } | xargs -r -d '\n' "$@"
  }

  for rev in ${TARGETS}; do
    jj edit "${rev}"
    FILES="$(jj diff -r "${rev}" --name-only --no-pager)"
    run_fmt '[.][ch]$' clang-format --style=file -i
    run_fmt '[.]py$' black
    run_fmt '[.]nix$' alejandra
  done
  restore
fi

exec jj "${SUBCMD[@]}" "${PASS[@]}"
