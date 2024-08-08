import PackageDescription

let package = Package(
  name: "SwiftTreats",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "SwiftTreats",
      targets: ["SwiftTreats"])
  ],
  dependencies: [
    .package(url: "_", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "SwiftTreats",
      dependencies: [
        .product(name: "OrderedCollections", package: "swift-collections")
      ]),
    .testTarget(
      name: "SwiftTreatsTests",
      dependencies: ["SwiftTreats"]),
  ]
)
