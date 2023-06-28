import PackageDescription

let package = Package(
    name: "SwiftTreats",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "SwiftTreats",
            targets: ["SwiftTreats"])
    ],
    dependencies: [
                    ],
    targets: [
                        .target(
            name: "SwiftTreats",
            dependencies: []),
        .testTarget(
            name: "SwiftTreatsTests",
            dependencies: ["SwiftTreats"])
    ]
)
