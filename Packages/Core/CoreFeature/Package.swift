import PackageDescription

let package = Package(
  name: "CoreFeature",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "CoreFeature", targets: ["CoreFeature"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreFeature",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "Argon2", package: "CyrilKit"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]),
    .testTarget(
      name: "CoreFeatureTests",
      dependencies: [
        "CoreFeature",
        .product(name: "CoreTypes", package: "CoreTypes"),
      ]),
  ]
)
