import PackageDescription

let package = Package(
  name: "DocumentServices",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "DocumentServices",
      targets: ["DocumentServices"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Core/CoreNetworking"),
    .package(name: "CorePersonalData", path: "../../Core/CorePersonalData"),
    .package(path: "../../Foundation/SwiftTreats"),
  ],
  targets: [
    .target(
      name: "DocumentServices",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "CoreNetworking", package: "CoreNetworking"),
        .product(name: "CorePersonalData", package: "CorePersonalData"),
      ]
    ),
    .testTarget(
      name: "DocumentServicesTests",
      dependencies: [
        "DocumentServices",
        .product(name: "CoreNetworking", package: "CoreNetworking"),
      ],
      resources: [
        .process("Test Resouces"),
        .process("AttachableObjects.xcdatamodeld"),
        .process("GeneratedClasses"),
      ]
    ),
    .testTarget(
      name: "DocumentServicesIntegrationTests",
      dependencies: [
        "DocumentServices",
        .product(name: "CoreNetworking", package: "CoreNetworking"),
      ]
    ),
  ]
)
