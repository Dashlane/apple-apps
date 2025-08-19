import PackageDescription

let package = Package(
  name: "CoreMainMenu",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "CoreMainMenu",
      targets: ["CoreMainMenu"])
  ],
  dependencies: [
    .package(path: "../CoreLocalization"),
    .package(path: "../../Foundation/SwiftTreats"),

  ],
  targets: [
    .target(
      name: "CoreMainMenu",
      dependencies: [
        .product(name: "CoreLocalization", package: "CoreLocalization"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
      ]
    ),
    .testTarget(
      name: "CoreMainMenuTests",
      dependencies: ["CoreMainMenu"]
    ),
  ]
)
