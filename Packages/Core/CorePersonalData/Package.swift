import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "CorePersonalData",
  platforms: [
    .iOS(.v17), .macOS(.v14),
  ],
  products: [
    .library(
      name: "CorePersonalData",
      targets: ["CorePersonalData"]
    )
  ],
  dependencies: [
    .package(path: "PersonalDataSpec"),
    .package(path: "../../Core/CoreTypes"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/DatabaseFoundation"),
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/CodableCSV"),
    .package(path: "../../Foundation/DashlaneAPI"),
    .package(path: "../../Foundation/LogFoundation"),
    .package(url: "_", branch: "master"),
    .package(url: "_", from: "510.0.0"),
  ],
  targets: [
    .macro(
      name: "PersonalDataMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "CorePersonalData",
      dependencies: [
        .product(name: "DatabaseFoundation", package: "DatabaseFoundation"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "DomainParser", package: "swiftdomainparser"),
        .product(name: "CyrilKit", package: "CyrilKit"),
        .product(name: "CodableCSV", package: "CodableCSV"),
        .product(name: "DashlaneAPI", package: "DashlaneAPI"),
        .product(name: "LogFoundation", package: "LogFoundation"),
        "PersonalDataMacros",
      ]),
    .testTarget(
      name: "CorePersonalDataTests",
      dependencies: [
        .target(name: "CorePersonalData", condition: .when(platforms: [.iOS])),
        .product(name: "PersonalDataSpec", package: "PersonalDataSpec"),
      ],
      resources: [
        .process("Resources")
      ]),
    .testTarget(
      name: "PersonalDataMacrosTests",
      dependencies: [
        .target(name: "PersonalDataMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]),
  ]
)
