import PackageDescription

let package = Package(
  name: "CorePasswords",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CorePasswords",
      targets: ["CorePasswords"])
  ],
  dependencies: [
    .package(name: "CoreTypes", path: "../../Core/CoreTypes"),
    .package(url: "_", branch: "main"),
  ],
  targets: [
    .target(
      name: "CorePasswords",
      dependencies: [
        "CoreTypes",
        .product(name: "ZXCVBN", package: "zxcvbnswift"),

      ],
      resources: [
        .process("version"),
        .process("Resource"),
      ]
    ),
    .testTarget(
      name: "CorePasswordsTests",
      dependencies: [
        "CorePasswords"
      ]
    ),
    .testTarget(
      name: "CorePasswordsPerformanceTests",
      dependencies: [
        "CorePasswords"
      ]
    ),
  ]
)
