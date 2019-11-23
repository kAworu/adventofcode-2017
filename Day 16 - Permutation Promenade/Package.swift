// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "PermutationPromenade",
    products: [
      .library(
        name: "PermutationPromenade",
        targets: ["PermutationPromenade"]),
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
            name: "PermutationPromenade",
            dependencies: ["Regex"]),
        .target(
            name: "Main",
            dependencies: ["PermutationPromenade"]),
        .testTarget(
            name: "PermutationPromenadeTests",
            dependencies: ["PermutationPromenade"]),
    ]
)
