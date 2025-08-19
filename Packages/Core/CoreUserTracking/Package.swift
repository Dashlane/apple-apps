import PackageDescription

let package = Package(
  name: "CoreUserTracking",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreUserTracking",
      targets: ["CoreUserTracking"]
    )
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/UserTrackingFoundation"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreUserTracking",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "UserTrackingFoundation", package: "UserTrackingFoundation"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]
    ),
    .testTarget(name: "CoreUserTrackingTests", dependencies: ["CoreUserTracking"]),
  ]
)
