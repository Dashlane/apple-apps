import PackageDescription

let package = Package(
  name: "DatabaseFoundation",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "DatabaseFoundation",
      targets: ["DatabaseFoundation"])
  ],
  dependencies: [
    .package(url: "_", from: "6.29.1")
  ],
  targets: [
    .target(
      name: "DatabaseFoundation",
      dependencies: [.product(name: "GRDB", package: "GRDB.swift")]),
    .testTarget(
      name: "DatabaseFoundationTests",
      dependencies: ["DatabaseFoundation"]),
  ]
)
