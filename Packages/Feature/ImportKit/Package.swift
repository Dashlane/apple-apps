import PackageDescription

let package = Package(
  name: "ImportKit",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CSVParser",
      targets: ["CSVParser"]),
    .library(
      name: "ImportKit",
      targets: ["ImportKit"]),
  ],
  dependencies: [
    .package(path: "../../Core/CoreSession"),
    .package(path: "../../Core/CoreLocalization"),
    .package(path: "../../Core/CorePersonalData"),
    .package(path: "../../Core/UIComponents"),
    .package(path: "../../Core/DesignSystem"),
    .package(path: "../../Plugins/swiftgen-plugin"),
    .package(path: "../../Plugins/sourcery-plugin"),
    .package(path: "../LoginKit"),
    .package(path: "../VaultKit"),
    .package(path: "../../Core/IconLibrary"),
    .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
    .package(name: "CoreFeature", path: "../../Core/CoreFeature"),
    .package(path: "../../Foundation/TOTPGenerator"),
  ],
  targets: [
    .target(
      name: "CSVParser",
      dependencies: []
    ),
    .target(
      name: "ImportKit",
      dependencies: [
        "CSVParser",
        .product(name: "CoreLocalization", package: "CoreLocalization"),
        .product(name: "DesignSystem", package: "DesignSystem"),
        .product(name: "CorePersonalData", package: "CorePersonalData"),
        .product(name: "CoreUserTracking", package: "CoreUserTracking"),
        .product(name: "LoginKit", package: "LoginKit"),
        .product(name: "VaultKit", package: "VaultKit"),
        .product(name: "CoreSession", package: "CoreSession"),
        .product(name: "UIComponents", package: "UIComponents"),
        .product(name: "IconLibrary", package: "IconLibrary"),
        .product(name: "TOTPGenerator", package: "TOTPGenerator"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "CSVParserTests",
      dependencies: ["CSVParser"],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "ImportKitTests",
      dependencies: ["CSVParser", "ImportKit"]
    ),
  ]
)
