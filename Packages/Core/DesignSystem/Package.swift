import PackageDescription

let package = Package(
  name: "DesignSystem",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]
    ),
    .library(
      name: "DesignSystemExtra",
      targets: ["DesignSystemExtra"]
    ),
  ],
  dependencies: [
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
      resources: [
        .process("Resources/Assets.xcassets"),
        .process("Resources/Fonts"),
      ]
    ),
    .target(
      name: "DesignSystemExtra",
      dependencies: [
        .target(name: "DesignSystem")
      ]
    ),
    .testTarget(
      name: "DesignSystemTests",
      dependencies: ["DesignSystem"]
    ),
  ]
)
