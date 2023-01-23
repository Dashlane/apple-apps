import PackageDescription

let package = Package(
    name: "DashlaneAPI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "DashlaneAPI",
            targets: ["DashlaneAPI"]),
    ],
    dependencies: [

    ],
    targets: [
                        .target(
            name: "DashlaneAPI",
            dependencies: []),
        .testTarget(
            name: "DashlaneAPITests",
            dependencies: ["DashlaneAPI"])

    ]
)
