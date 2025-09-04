import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "LogFoundation",
  platforms: [.macOS(.v11), .iOS(.v17), .macCatalyst(.v17)],
  products: [
    .library(
      name: "LogFoundation",
      targets: ["LogFoundation"]
    ),
    .executable(
      name: "LogFoundationClient",
      targets: ["LogFoundationClient"]
    ),
  ],
  dependencies: [
    .package(url: "_", from: "510.0.0")
  ],
  targets: [
    .macro(
      name: "LogFoundationMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    .target(name: "LogFoundation", dependencies: ["LogFoundationMacros"]),

    .executableTarget(name: "LogFoundationClient", dependencies: ["LogFoundation"]),

    .testTarget(
      name: "LogFoundationTests",
      dependencies: [
        "LogFoundationMacros",
        "LogFoundation",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
