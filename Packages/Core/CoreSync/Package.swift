import PackageDescription

let package = Package(
  name: "CoreSync",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "CoreSync", targets: ["CoreSync"])
  ],
  dependencies: [
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Core/CorePersonalData"),
    .package(path: "../../Core/CoreCrypto"),
  ],
  targets: [
    .target(
      name: "CoreSync",
      dependencies: [
        "DashTypes",
        "CyrilKit",
        "DashlaneAPI",
      ]
    ),
    .testTarget(
      name: "CoreSyncTests",
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
