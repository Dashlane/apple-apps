import PackageDescription

let package = Package(
  name: "CoreSync",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "CoreSync", targets: ["CoreSync"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Core/CorePersonalData"),
    .package(path: "../../Core/CoreCrypto"),
  ],
  targets: [
    .target(
      name: "CoreSync",
      dependencies: [
        "CoreTypes",
        "CyrilKit",
        "DashlaneAPI",
      ]
    ),
    .testTarget(
      name: "CoreSyncTests",
      dependencies: [
        "CoreSync"
      ]
    ),
    .testTarget(
      name: "CoreSyncLegacyTests",
      dependencies: [
        "CoreSync",
        "CoreCrypto",
        "CorePersonalData",
        "DashlaneAPI",
      ],
      resources: [
        .process("Sync/Resources/")
      ]
    ),
  ]
)
