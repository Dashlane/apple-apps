import PackageDescription

let package = Package(
    name: "CoreCategorizer",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "CoreCategorizer",
            targets: ["CoreCategorizer"])
    ],
    dependencies: [],
    targets: [
                        .target(
            name: "CoreCategorizer",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "CoreCategorizerTests",
            dependencies: [
                "CoreCategorizer"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "CoreCategorizerPerformanceTests",
            dependencies: [
                "CoreCategorizer"
            ]
        )
    ]
)
