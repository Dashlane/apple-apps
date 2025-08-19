import PackageDescription

let package = Package(
  name: "CoreKeychain",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreKeychain",
      targets: ["CoreKeychain"])
  ],
  dependencies: [
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/CyrilKit"),
  ],
  targets: [
    .target(
      name: "CoreKeychain",
      dependencies: [
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "CyrilKit", package: "CyrilKit"),
      ]
    )
  ]
)
