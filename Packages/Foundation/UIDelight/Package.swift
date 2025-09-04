import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "UIDelight",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "UIDelight",
      targets: ["UIDelight"])
  ],
  dependencies: [
    .package(url: "_", from: "510.0.0")
  ],
  targets: [
    .target(
      name: "UIDelight",
      dependencies: [
        .target(name: "UIDelightMacros")
      ]
    ),
    .testTarget(
      name: "UIDelightTests",
      dependencies: [
        .target(name: "UIDelight"),
        .target(name: "UIDelightMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    .macro(
      name: "UIDelightMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
  ]
)
