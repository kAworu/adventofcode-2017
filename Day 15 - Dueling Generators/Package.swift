// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "DuelingGenerators",
    products: [
      .library(
        name: "DuelingGenerators",
        targets: ["DuelingGenerators"]),
      .library(
        name: "MINSTD",
        targets: ["MINSTD"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can
        // define a module or a test suite. Targets can depend on other targets
        // in this package, and on products in packages which this package
        // depends on.
        .target(
            name: "MINSTD"),
        .target(
            name: "DuelingGenerators",
            dependencies: ["MINSTD"]),
        .target(
            name: "Main",
            dependencies: ["DuelingGenerators", "Regex"]),
        .testTarget(
            name: "DuelingGeneratorsTests",
            dependencies: ["DuelingGenerators"]),
    ]
)
