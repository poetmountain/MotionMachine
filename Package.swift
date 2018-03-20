import PackageDescription

let package = Package(
    name: "MotionMachine",
    targets: [
        .target(name: "MotionMachine", dependencies: []),
        .testTarget(name: "MotionMachineTests", dependencies: []),
    ]
)