import PackageDescription

let package = Package(
    name: "IconLibrary",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "IconLibrary",
            targets: ["IconLibrary"])
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/UIDelight"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Plugins/swiftgen-plugin")
    ],
    targets: [
                        .target(
            name: "IconLibrary",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "UIDelight", package: "UIDelight")
            ]),
        .testTarget(
            name: "IconLibraryTests",
            dependencies: ["IconLibrary"],
            resources: [
                .process("Resources/")
            ])
    ]
)
