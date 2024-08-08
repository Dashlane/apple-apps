import PackageDescription

let package = Package(
  name: "CoreKeychain",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CoreKeychain",
      targets: ["CoreKeychain"])
  ],
  dependencies: [
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/CyrilKit"),
  ],
  targets: [
    .target(
      name: "CoreKeychain",
      dependencies: [
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "CyrilKit", package: "CyrilKit"),
      ]
    )
  ]
)
