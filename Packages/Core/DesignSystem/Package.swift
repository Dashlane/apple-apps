import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .executable(
            name: "DesignSystemGenerator",
            targets: ["DesignSystemGenerator"])
    ],
    dependencies: [
                .package(url: "_", from: "1.2.0"),
        .package(path: "../../Foundation/UIDelight"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Plugins/swiftgen-plugin")
    ],
    targets: [
                        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "UIDelight", package: "UIDelight"),
                .product(name: "CoreLocalization", package: "CoreLocalization")
            ],
            exclude: ["Resources/swiftgen.yml",
                      "Resources/swift5-color.stencil",
                      "Resources/swift5-images.stencil"],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .executableTarget(
            name: "DesignSystemGenerator",
            dependencies: [
                                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/Generator"
        ),
        .testTarget(
            name: "DesignSystemGeneratorTests",
            dependencies: ["DesignSystemGenerator"],
            path: "Tests/GeneratorTests"
        )
    ]
)
