import PackageDescription

let package = Package(
  name: "CoreSession",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreSession",
      targets: ["CoreSession"]
    )
  ],
  dependencies: [
    .package(path: "../../Core/CoreNetworking"),
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/StateMachine"),
    .package(path: "../../Foundation/UserTrackingFoundation"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreSession",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "CoreNetworking", package: "CoreNetworking"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "StateMachine", package: "StateMachine"),
        .product(name: "UserTrackingFoundation", package: "UserTrackingFoundation"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "CoreSessionTests",
      dependencies: [
        "CoreSession",
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "StateMachineTesting", package: "StateMachine"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
