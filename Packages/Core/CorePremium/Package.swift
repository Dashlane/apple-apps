import PackageDescription

let package = Package(
  name: "CorePremium",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CorePremium",
      targets: ["CorePremium"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CorePremium",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]),
    .testTarget(
      name: "CorePremiumTests",
      dependencies: [
        "CorePremium",
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ]
    ),
  ]
)
