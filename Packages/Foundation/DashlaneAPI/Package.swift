import Foundation
import PackageDescription

var swiftSettings: [SwiftSetting] = []
if ProcessInfo.processInfo.environment["BUILD_TYPE"] == "nightly" {
  swiftSettings.append(.define("NIGHTLY"))
}

let package = Package(
  name: "DashlaneAPI",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "DashlaneAPI",
      targets: ["DashlaneAPI"])
  ],
  dependencies: [
    .package(url: "_", .upToNextMajor(from: "2.6.0"))
  ],
  targets: [
    .target(
      name: "DashlaneAPI",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux]))
      ],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "DashlaneAPITests",
      dependencies: ["DashlaneAPI"]),

  ]
)
