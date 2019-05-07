#!/bin/sh

# prevent shift error
[ $# -ge 2 ] && [ -n "$1" ] || exit 1

split_version() {
    local VARPREFIX
    local NUMBERS
    local major
    local minor

    VARPREFIX=$1
    NUMBERS=$2

    major=${NUMBERS%%\.*}
    NUMBERS=${NUMBERS#$major}; NUMBERS=${NUMBERS#\.}
    minor=${NUMBERS%%\.*}
    NUMBERS=${NUMBERS#$minor}; NUMBERS=${NUMBERS#\.}

    # ensure that missing values are 0
    eval "${VARPREFIX}_major=\$major; ${VARPREFIX}_minor=\$((minor + 0)); ${VARPREFIX}_bugfix=\$((NUMBERS + 0));"
}

split_version req "$1"

shift

for candidate; do

    # Try to locate the candidate. Discard it if not located.
    tool=$(which "${candidate}" 2>/dev/null)
    [ -n "${tool}" ] || continue

    split_version cur "$("${tool}" --version)"

    [ -n "${cur_major}" -a "${cur_major}" -ge "${req_major}" ] || continue
    [ "${cur_major}" -gt "${req_major}" ] || [ "${cur_minor}" -ge "${req_minor}" ] || continue
    [ "${cur_minor}" -gt "${req_minor}" ] || [ "${cur_bugfix}" -ge "${req_bugfix}" ] || continue

    echo "${tool}"
    exit
done

# echo nothing: no suitable tool found
exit 1
