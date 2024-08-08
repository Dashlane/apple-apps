import PackageDescription

let package = Package(
  name: "IconLibrary",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "IconLibrary",
      targets: ["IconLibrary"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/UIDelight"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Core/DesignSystem"),
    .package(path: "../../Plugins/swiftgen-plugin"),
    .package(url: "_", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "IconLibrary",
      dependencies: [
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DesignSystem", package: "DesignSystem"),
        .product(name: "UIDelight", package: "UIDelight"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "OrderedCollections", package: "swift-collections"),
      ]),
    .testTarget(
      name: "IconLibraryTests",
      dependencies: ["IconLibrary"],
      resources: [
        .process("Resources/")
      ]),
  ]
)
