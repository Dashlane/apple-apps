import PackageDescription

let package = Package(
  name: "CoreIPC",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreIPC",
      targets: ["CoreIPC"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreIPC",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]),
    .testTarget(
      name: "CoreIPCTests",
      dependencies: [
        "CoreIPC",
        .product(name: "CoreTypes", package: "CoreTypes"),
      ]
    ),
    .testTarget(
      name: "CoreIPCPerformanceTests",
      dependencies: ["CoreIPC"]
    ),
  ]
)
