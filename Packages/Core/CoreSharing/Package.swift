import PackageDescription

let package = Package(
  name: "CoreSharing",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CoreSharing",
      targets: ["CoreSharing"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DatabaseFoundation"),
  ],
  targets: [
    .target(
      name: "CoreSharing",
      dependencies: [
        .product(name: "DatabaseFoundation", package: "DatabaseFoundation"),
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "CyrilKit", package: "CyrilKit"),
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
