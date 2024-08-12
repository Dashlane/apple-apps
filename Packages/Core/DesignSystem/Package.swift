import PackageDescription

let package = Package(
  name: "DesignSystem",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]),
    .executable(
      name: "DesignSystemGenerator",
      targets: ["DesignSystemGenerator"]),
  ],
  dependencies: [
    .package(url: "_", from: "1.2.0"),
    .package(path: "../../Foundation/UIDelight"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Core/CoreLocalization"),
    .package(path: "../../Plugins/swiftgen-plugin"),
  ],
  targets: [
    .target(
      name: "DesignSystem",
      dependencies: [
        .product(name: "UIDelight", package: "UIDelight"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "CoreLocalization", package: "CoreLocalization"),
      ],
      exclude: [
        "Resources/swiftgen.yml",
        "Resources/swift5-color.stencil",
        "Resources/swift5-images.stencil",
        "Resources/swift5-text-styles.stencil",
      ],
      resources: [
        .process("Resources/Assets.xcassets"),
        .process("Resources/Fonts"),
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
    ),
    .testTarget(
      name: "DesignSystemTests",
      dependencies: ["DesignSystem"]
    ),
  ]
)
