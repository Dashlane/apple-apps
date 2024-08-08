import Darwin.C
import PackageDescription

var swiftSettings: [SwiftSetting] = []
if let envPointer = getenv("INTEGRATION_TEST") {
  let integrationTest = String(cString: envPointer)

  if !integrationTest.isEmpty {
    swiftSettings.append(.define("INTEGRATION_TEST"))
  }
}

if let envPointer = getenv("BUILD_TYPE") {
  let buildType = String(cString: envPointer)

  if buildType == "nightly" {
    swiftSettings.append(.define("NIGHTLY"))
  }
}

let package = Package(
  name: "CoreNetworking",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "CoreNetworking", targets: ["CoreNetworking"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
  ],
  targets: [
    .target(
      name: "CoreNetworking",
      dependencies: ["DashTypes", "DashlaneAPI"],
      swiftSettings: swiftSettings)
  ]
)
