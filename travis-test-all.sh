#!/usr/bin/env bash

set -e

DIR=$(dirname "$0")
TRAVIS_OS_NAME=$1
DAYS=$(find "$DIR" -maxdepth 1 -type d -name 'Day [0-9]*' | sort)

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    export SWIFTENV_ROOT="$HOME/.swiftenv"
    export PATH="$SWIFTENV_ROOT/bin:$SWIFTENV_ROOT/shims:$PATH"
fi

echo "$DAYS" | while read DAY; do
    echo "===>" $(basename "$DAY")
    (cd "$DAY" && swift test --verbose)
done
