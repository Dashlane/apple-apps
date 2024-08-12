import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "CorePersonalData",
  platforms: [
    .iOS(.v16), .macOS(.v13),
  ],
  products: [
    .library(
      name: "CorePersonalData",
      targets: ["CorePersonalData"]
    )
  ],
  dependencies: [
    .package(path: "PersonalDataSpec"),
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/SwiftTreats"),
    .package(path: "../../Foundation/DatabaseFoundation"),
    .package(path: "../../Foundation/CyrilKit"),
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
        .product(name: "DashTypes", package: "DashTypes"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "DomainParser", package: "swiftdomainparser"),
        .product(name: "CyrilKit", package: "CyrilKit"),
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
