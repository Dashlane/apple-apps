import PackageDescription

let package = Package(
  name: "CoreTeamAuditLogs",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreTeamAuditLogs",
      targets: ["CoreTeamAuditLogs"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreTeamAuditLogs",
      dependencies: ["DashlaneAPI", "CoreTypes", "LogFoundation"]),
    .testTarget(
      name: "CoreTeamAuditLogsTests",
      dependencies: ["CoreTeamAuditLogs"]),
  ]
)
