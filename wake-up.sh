#!/bin/sh
#
# Create a directory and generate template files for a given day. Ex:
#
#   ./wake-up.sh 01 "Inverse Captcha"

set -e

ROOT=$(dirname "$0")

if [ $# -ne 2 ]; then
    echo "usage $(basename "$0") DAY NAME" > /dev/stderr
    exit 1
fi

DAY=$1
NAME=$2
SLUG=$(echo "$NAME" | sed -e 's/[- ]//g')
TEST="${SLUG}Tests"

DAYDIR="${ROOT}/Day ${DAY} - ${NAME}"
SRCMAINFILE="${DAYDIR}/Sources/Main/Main.swift"
SRCFILE="${DAYDIR}/Sources/${SLUG}/${SLUG}.swift"
TESTMAINFILE="${DAYDIR}/Tests/LinuxMain.swift"
TESTFILE="${DAYDIR}/Tests/${TEST}/${TEST}.swift"

mkdir -p \
	"$(dirname "$SRCMAINFILE")"  \
	"$(dirname "$SRCFILE")"      \
	"$(dirname "$TESTMAINFILE")" \
	"$(dirname "$TESTFILE")"

# answer.md
cat <<EOF > "${DAYDIR}/answer.md"
Your puzzle answer was \`?\`.
EOF

# answer.part2.md
cat <<EOF > "${DAYDIR}/answer.part2.md"
Your puzzle answer was \`?\`.
EOF

# input.txt
: > "${DAYDIR}/input.txt"

# Package.swift
cat <<EOF > "${DAYDIR}/Package.swift"
// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "${SLUG}",
    products: [
      .library(
        name: "${SLUG}",
        targets: ["${SLUG}"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can
        // define a module or a test suite. Targets can depend on other targets
        // in this package, and on products in packages which this package
        // depends on.
        .target(
            name: "${SLUG}"),
        .target(
            name: "Main",
            dependencies: ["${SLUG}"]),
        .testTarget(
            name: "${TEST}",
            dependencies: ["${SLUG}"]),
    ]
)
EOF

# README.md
: > "${DAYDIR}/README.md"

# README.part2.md
: > "${DAYDIR}/README.part2.md"

# Code files
: > "$SRCFILE"

# Swift code file
cat <<EOF > "$SRCFILE"
public class ${SLUG} {
  // TODO
}
EOF

# Main file
cat <<EOF > "$SRCMAINFILE"
import ${SLUG}

// TODO
EOF

# Tests' LinuxMain.swift
cat <<EOF > "$TESTMAINFILE"
import XCTest
@testable import ${TEST}

XCTMain([
    testCase(${TEST}.allTests),
])
EOF

# Swift tests file
cat <<EOF > "$TESTFILE"
import XCTest
@testable import ${SLUG}

class ${TEST}: XCTestCase {

  func testPartOne() {
    // TODO
  }

  func testPartTwo() {
    // TODO
  }
}

#if os(Linux)
extension ${TEST} {
  static var allTests: [(String, (${TEST}) -> () throws -> Void)] {
    return [
      ("testPartOne", testPartOne),
      ("testPartTwo", testPartTwo),
    ]
  }
}
#endif
EOF
