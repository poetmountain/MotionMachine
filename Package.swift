// swift-tools-version: 6.0

//  Package.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import PackageDescription

let package = Package(
    name: "MotionMachine",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .visionOS(.v1),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MotionMachine", targets: ["MotionMachine"])
    ],
    targets: [
        .target(name: "MotionMachine", path: "Sources/"),
        .testTarget(
            name: "MotionMachineTests",
            dependencies: ["MotionMachine"],
            path: "Tests/Tests/"
        )
    ],
    swiftLanguageModes: [.v6]
)
