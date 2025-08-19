import PackageDescription

let package = Package(
  name: "CoreSharing",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreSharing",
      targets: ["CoreSharing"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DatabaseFoundation"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreSharing",
      dependencies: [
        .product(name: "DatabaseFoundation", package: "DatabaseFoundation"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]),
    .testTarget(
      name: "CoreSharingTests",
      dependencies: [
        "CoreSharing"
      ],
      resources: [
        .process("Resources")
      ]),
  ]
)
