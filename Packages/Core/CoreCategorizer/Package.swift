import PackageDescription

let package = Package(
    name: "CoreCategorizer",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "CoreCategorizer",
            targets: ["CoreCategorizer"]),
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
                "CoreCategorizer",
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
