import PackageDescription

let package = Package(
  name: "CoreSettings",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CoreSettings",
      targets: ["CoreSettings"])
  ],
  dependencies: [
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/LogFoundation"),
  ],
  targets: [
    .target(
      name: "CoreSettings",
      dependencies: [
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ],
      resources: [
        .process("Resources"),
        .process("GeneratedClasses/SettingsDataModel.momd"),
      ]
    ),
    .testTarget(
      name: "CoreSettingsTests",
      dependencies: ["CoreSettings"],
      resources: [
        .process("TestModel.xcdatamodeld"),
        .process("GeneratedClasses/TestModel.momd"),
      ]
    ),
  ]
)
