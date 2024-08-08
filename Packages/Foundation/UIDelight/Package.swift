import PackageDescription

let package = Package(
  name: "UIDelight",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "UIDelight",
      targets: ["UIDelight"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "UIDelight",
      dependencies: []),
    .testTarget(
      name: "UIDelightTests",
      dependencies: ["UIDelight"]),
  ]
)
