import PackageDescription

let package = Package(
  name: "CoreSession",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "CoreSession",
      targets: ["CoreSession"]
    )
  ],
  dependencies: [
    .package(path: "../../Core/CoreNetworking"),
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/StateMachine"),
  ],
  targets: [
    .target(
      name: "CoreSession",
      dependencies: [
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "CoreNetworking", package: "CoreNetworking"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "StateMachine", package: "StateMachine"),
      ]
    ),
    .testTarget(
      name: "CoreSessionTests",
      dependencies: [
        "CoreSession",
        .product(name: "DashTypes", package: "DashTypes"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
