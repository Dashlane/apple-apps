import PackageDescription

let package = Package(
  name: "CyrilKit",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CyrilKit",
      targets: ["CyrilKit"]),
    .library(
      name: "Argon2",
      targets: ["Argon2"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Argon2",
      cSettings: [
        .headerSearchPath("include")
      ]),
    .target(
      name: "CyrilKit",
      dependencies: ["Argon2"]),
    .testTarget(
      name: "CyrilKitTests",
      dependencies: ["CyrilKit"]),
  ]
)
