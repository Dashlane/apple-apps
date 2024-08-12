import PackageDescription

let package = Package(
  name: "PremiumKit",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "PremiumKit",
      targets: ["PremiumKit"])
  ],
  dependencies: [
    .package(path: "../../Common/documentservices"),
    .package(path: "../../Core/CorePremium"),
    .package(path: "../../Core/CoreSession"),
    .package(path: "../../Core/CorePersonalData"),
    .package(path: "../../Core/CoreSharing"),
    .package(path: "../../Core/CoreSync"),
    .package(path: "../../Core/CoreLocalization"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Plugins/swiftgen-plugin"),
    .package(path: "../../Core/IconLibrary"),
    .package(path: "../../Foundation/UIDelight"),
    .package(path: "../../Core/UIComponents"),
    .package(path: "../../Core/CoreSettings"),
    .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
  ],
  targets: [
    .target(
      name: "PremiumKit",
      dependencies: [
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "CoreSession", package: "CoreSession"),
        .product(name: "CoreSettings", package: "CoreSettings"),
        .product(name: "DocumentServices", package: "DocumentServices"),
        .product(name: "CorePersonalData", package: "CorePersonalData"),
        .product(name: "CoreLocalization", package: "CoreLocalization"),
        .product(name: "CorePremium", package: "CorePremium"),
        .product(name: "CoreUserTracking", package: "CoreUserTracking"),
        .product(name: "CoreSync", package: "CoreSync"),
        .product(name: "CoreSharing", package: "CoreSharing"),
        .product(name: "IconLibrary", package: "IconLibrary"),
        .product(name: "UIComponents", package: "UIComponents"),
        .product(name: "UIDelight", package: "UIDelight"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(name: "PremiumKitTests", dependencies: ["PremiumKit"]),
  ]
)
