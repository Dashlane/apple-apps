import PackageDescription

let package = Package(
    name: "DatabaseFoundation",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "DatabaseFoundation",
            targets: ["DatabaseFoundation"]),
    ],
    dependencies: [
        .package(url: "_", from: "5.22.2")
    ],
    targets: [
                        .target(
            name: "DatabaseFoundation",
            dependencies: [.product(name: "GRDB", package: "GRDB")]),
        .testTarget(
            name: "DatabaseFoundationTests",
            dependencies: ["DatabaseFoundation"]),
    ]
)
