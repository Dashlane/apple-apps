import PackageDescription

let package = Package(
  name: "CoreActivityLogs",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CoreActivityLogs",
      targets: ["CoreActivityLogs"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/DashTypes"),
  ],
  targets: [
    .target(
      name: "CoreActivityLogs",
      dependencies: ["DashlaneAPI", "DashTypes"]),
    .testTarget(
      name: "CoreActivityLogsTests",
      dependencies: ["CoreActivityLogs"]),
  ]
)
