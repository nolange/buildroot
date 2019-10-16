#!/bin/sh

readversion() {
	"$1" --version |
		sed -r -e '/.* ([[:digit:]]+\.[[:digit:]]+).*$/!d;' -e 's//\1/'
}

. "$(dirname "$(readlink -e "$0")")"/versioncheck.sh
