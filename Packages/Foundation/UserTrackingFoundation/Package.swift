import PackageDescription

let package = Package(
  name: "UserTrackingFoundation",
  products: [
    .library(
      name: "UserTrackingFoundation",
      targets: ["UserTrackingFoundation"])
  ],
  targets: [
    .target(
      name: "UserTrackingFoundation"),
    .testTarget(
      name: "UserTrackingFoundationTests",
      dependencies: ["UserTrackingFoundation"]
    ),
  ]
)
