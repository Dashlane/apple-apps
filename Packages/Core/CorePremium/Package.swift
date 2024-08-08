import PackageDescription

let package = Package(
  name: "CorePremium",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CorePremium",
      targets: ["CorePremium"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
  ],
  targets: [
    .target(
      name: "CorePremium",
      dependencies: [
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ]),
    .testTarget(
      name: "CorePremiumTests",
      dependencies: [
        "CorePremium",
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ]
    ),
  ]
)
