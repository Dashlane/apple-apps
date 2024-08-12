import PackageDescription

let package = Package(
  name: "Logger",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "Logger",
      targets: ["Logger"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
  ],
  targets: [
    .target(
      name: "Logger",
      dependencies: [
        "DashTypes",
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ])
  ]
)
