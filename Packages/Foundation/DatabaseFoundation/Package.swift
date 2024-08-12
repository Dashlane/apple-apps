import PackageDescription

let package = Package(
  name: "DatabaseFoundation",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "DatabaseFoundation",
      targets: ["DatabaseFoundation"])
  ],
  dependencies: [
    .package(url: "_", from: "6.20.2")
  ],
  targets: [
    .target(
      name: "DatabaseFoundation",
      dependencies: [.product(name: "GRDB", package: "GRDB")]),
    .testTarget(
      name: "DatabaseFoundationTests",
      dependencies: ["DatabaseFoundation"]),
  ]
)
