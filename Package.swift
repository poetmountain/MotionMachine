// swift-tools-version: 5.10

//  Package.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import PackageDescription

let package = Package(
    name: "MotionMachine",
    platforms: [
        .iOS(.v13), .tvOS(.v13)
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
    swiftLanguageVersions: [.v5]
)
