import PackageDescription

let package = Package(
  name: "UIComponents",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "UIComponents",
      targets: ["UIComponents"])
  ],
  dependencies: [
    .package(path: "../../Foundation/UIDelight"),
    .package(path: "../../Core/DesignSystem"),
    .package(url: "_", "4.0.1"..<"5.0.0"),
    .package(path: "../../Plugins/swiftgen-plugin"),
    .package(name: "CoreUserTracking", path: "../CoreUserTracking"),
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../CoreLocalization"),
  ],
  targets: [
    .target(
      name: "UIComponents",
      dependencies: [
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DesignSystem", package: "DesignSystem"),
        .product(name: "UIDelight", package: "UIDelight"),
        .product(name: "CoreUserTracking", package: "CoreUserTracking"),
        .product(name: "Lottie", package: "lottie-ios"),
        .product(name: "CoreLocalization", package: "CoreLocalization"),
      ],
      exclude: ["Resources/swiftgen.yml"],
      resources: [.process("Resources")]
    )
  ]
)
