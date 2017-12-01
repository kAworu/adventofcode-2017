#!/usr/bin/env bash

set -e

DIR=$(dirname "$0")
DAYS=$(find "$DIR" -maxdepth 1 -type d -name 'Day [0-9]*')

# see .travis.yml
if [ -f ~/.swiftenv/init ]; then
    source ~/.swiftenv/init
fi

echo "$DAYS" | while read DAY; do
    echo "===>" $(basename "$DAY")
    (cd "$DAY" && swift test --verbose)
done
