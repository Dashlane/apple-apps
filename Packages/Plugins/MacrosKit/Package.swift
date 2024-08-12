import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "MacrosKit",
  platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    .library(
      name: "MacrosKit",
      targets: ["MacrosKit"]
    ),
    .executable(
      name: "MacrosKitClient",
      targets: ["MacrosKitClient"]
    ),
  ],
  dependencies: [
    .package(url: "_", from: "510.0.0")
  ],
  targets: [
    .macro(
      name: "MacrosKitMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    .target(name: "MacrosKit", dependencies: ["MacrosKitMacros"]),

    .executableTarget(name: "MacrosKitClient", dependencies: ["MacrosKit"]),

    .testTarget(
      name: "MacrosKitTests",
      dependencies: [
        "MacrosKitMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
