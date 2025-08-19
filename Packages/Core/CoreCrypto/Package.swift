import PackageDescription

let package = Package(
  name: "CoreCrypto",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreCrypto",
      targets: ["CoreCrypto"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(url: "_", revision: "5b7e71852a1c1b46dd51c3f31c76747d9c82016e"),
    .package(url: "_", from: "0.5.0"),
  ],
  targets: [
    .target(
      name: "CoreCrypto",
      dependencies: [
        .product(name: "Sodium", package: "swift-sodium"),
        .product(name: "SwiftCBOR", package: "SwiftCBOR"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "Argon2", package: "CyrilKit"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ],
      resources: [.process("Resources")]),
    .testTarget(
      name: "CoreCryptoTests",
      dependencies: [
        "CoreCrypto",
        .product(name: "Argon2", package: "CyrilKit"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
      ],
      exclude: [
        "Resources/cryptotests/package.json",
        "Resources/cryptotests/README.md",
        "Resources/cryptotests/Resources",
      ],
      resources: [
        .copy("Resources/cryptotests/Tests/"),
        .copy("Resources/cryptotests/UniversalDeviceTransferTests/"),
        .process("Resources/local/"),
      ]),
  ]
)
