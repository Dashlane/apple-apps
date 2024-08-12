import PackageDescription

let package = Package(
  name: "DashTypes",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "DashTypes", targets: ["DashTypes"])
  ],
  dependencies: [
    .package(path: "../../Foundation/SwiftTreats")
  ],
  targets: [
    .target(
      name: "DashTypes",
      dependencies: [
        .product(name: "SwiftTreats", package: "SwiftTreats")
      ]
    ),
    .testTarget(
      name: "DashTypesUnitTests",
      dependencies: ["DashTypes"]),
  ]
)
