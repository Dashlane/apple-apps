import PackageDescription

let package = Package(
  name: "UIComponents",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "UIComponents",
      targets: ["UIComponents"])
  ],
  dependencies: [
    .package(path: "../../Foundation/UIDelight"),
    .package(path: "../../Core/DesignSystem"),
    .package(url: "_", from: "4.5.0"),
    .package(name: "CoreUserTracking", path: "../CoreUserTracking"),
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../CoreLocalization"),
  ],
  targets: [
    .target(
      name: "UIComponents",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DesignSystem", package: "DesignSystem"),
        .product(name: "UIDelight", package: "UIDelight"),
        .product(name: "CoreUserTracking", package: "CoreUserTracking"),
        .product(name: "Lottie", package: "lottie-ios"),
        .product(name: "CoreLocalization", package: "CoreLocalization"),
      ],
      resources: [.process("Resources")]
    )
  ]
)
