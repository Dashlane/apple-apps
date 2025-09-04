import PackageDescription

let package = Package(
  name: "CoreTypes",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "CoreTypes", targets: ["CoreTypes"])
  ],
  dependencies: [
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/LogFoundation"),

  ],
  targets: [
    .target(
      name: "CoreTypes",
      dependencies: [
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]
    ),
    .testTarget(
      name: "CoreTypesUnitTests",
      dependencies: ["CoreTypes"]),
  ]
)
