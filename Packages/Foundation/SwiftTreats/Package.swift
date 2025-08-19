import PackageDescription

let package = Package(
  name: "SwiftTreats",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
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
