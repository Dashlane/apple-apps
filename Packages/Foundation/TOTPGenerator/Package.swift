import PackageDescription

let package = Package(
    name: "TOTPGenerator",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "TOTPGenerator",
            targets: ["TOTPGenerator"]),
    ],
    dependencies: [
                    ],
    targets: [
        .target(
            name: "TOTPGenerator"
        ),
        .testTarget(
            name: "TOTPGeneratorTests",
            dependencies: ["TOTPGenerator"]
        ),
    ]
)
