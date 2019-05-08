#!/bin/sh

readversion() {
	"$1" --version
}

. "$(dirname "$(readlink -e "$0")")"/versioncheck.sh
