import PackageDescription

let package = Package(
  name: "CoreRegion",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreRegion",
      targets: ["CoreRegion"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "CoreRegion",
      exclude: ["Resources/region-information-resources/publishMaven"],
      resources: [
        .process("Resources")
      ]),

    .testTarget(
      name: "CoreRegionTests",
      dependencies: [
        "CoreRegion"
      ]),
    .testTarget(
      name: "CoreRegionPerformanceTests",
      dependencies: [
        "CoreRegion"
      ]),
  ]
)
