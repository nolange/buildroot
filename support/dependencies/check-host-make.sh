#!/bin/sh

readversion() {
	"$1" --version 2>&1 |
		sed -e 's/^.* \([0-9\.]\)/\1/g' -e 's/[-].*//g' -e '1q'
}

. "$(dirname "$(readlink -e "$0")")"/versioncheck.sh
