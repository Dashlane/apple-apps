import PackageDescription

let package = Package(
  name: "Logger",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Logger",
      targets: ["Logger"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "Logger",
      dependencies: [
        "CoreTypes",
        "LogFoundation",
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ])
  ]
)
