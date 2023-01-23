import PackageDescription

let package = Package(
    name: "UIDelight",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "UIDelight",
            targets: ["UIDelight"]),
    ],
    dependencies: [
                    ],
    targets: [
                        .target(
            name: "UIDelight",
            dependencies: []),
        .testTarget(
            name: "UIDelightTests",
            dependencies: ["UIDelight"]),
    ]
)
