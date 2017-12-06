#!/usr/bin/env bash

set -e

DIR=$(dirname "$0")
DAYS=$(find "$DIR" -maxdepth 1 -type d -name 'Day [0-9]*' | sort)

echo "$DAYS" | while read DAY; do
    echo "===>" $(basename "$DAY")
    # see .travis.yml
    if [ -f ~/.swiftenv/init ]; then
        cat ~/.swiftenv/init
        . ~/.swiftenv/init
    fi
    (cd "$DAY" && swift test --verbose)
done
