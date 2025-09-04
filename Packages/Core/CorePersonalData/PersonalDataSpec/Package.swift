import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "PersonalDataSpec",
  platforms: [
    .iOS(.v17), .macOS(.v14),
  ],
  products: [
    .library(
      name: "PersonalDataSpec",
      targets: ["PersonalDataSpec"]
    )
  ],
  dependencies: [
    .package(path: "../../../Foundation/SwiftTreats")
  ],
  targets: [
    .target(
      name: "PersonalDataSpec",
      dependencies: [
        "SwiftTreats"
      ],
      exclude: [
        "DataModel/README.md",
        "DataModel/check.sh",
      ],
      resources: [
        .copy("DataModel/examples"),
        .copy("DataModel/meta"),
        .copy("DataModel/schemas"),
      ]
    )
  ]
)
