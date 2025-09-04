import PackageDescription

let package = Package(
  name: "SecurityDashboard",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "SecurityDashboard",
      targets: ["SecurityDashboard"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/LogFoundation"),
    .package(path: "../../Foundation/DashlaneAPI"),
  ],
  targets: [
    .target(
      name: "SecurityDashboard",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ]
    ),
    .testTarget(
      name: "SecurityDashboardTests",
      dependencies: [
        "SecurityDashboard",
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ],
      exclude: [
        "Resources/common-unit-tests/CHANGELOG.md",
        "Resources/common-unit-tests/package-lock.json",
        "Resources/common-unit-tests/package.json",
        "Resources/common-unit-tests/README.md",
        "Resources/common-unit-tests/password-strength/README.md",
        "Resources/common-unit-tests/password-similarity/README.md",
      ],
      resources: [
        .process("Breaches/Resources"),
        .process("Resources/common-unit-tests/password-similarity/Tests"),
        .process("Resources/common-unit-tests/password-strength/Tests"),
      ]
    ),
    .testTarget(
      name: "SecurityDashboardPerformanceTests",
      dependencies: [
        "SecurityDashboard"
      ]
    ),
  ]
)
