// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MotionMachine",
    products: [
        .library(name: "MotionMachine", targets: ["MotionMachine"]),
    ],
    targets: [
        .target(name: "MotionMachine", dependencies: [], path: "Sources", exclude: "Tests"),
    ]
)