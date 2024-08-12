import PackageDescription

let package = Package(
  name: "CoreUserTracking",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CoreUserTracking",
      targets: ["CoreUserTracking"]
    )
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/SwiftTreats"),
  ],
  targets: [
    .target(
      name: "CoreUserTracking",
      dependencies: [
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
      ]
    ),
    .testTarget(name: "CoreUserTrackingTests", dependencies: ["CoreUserTracking"]),
  ]
)
