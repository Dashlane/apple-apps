import PackageDescription

let package = Package(
  name: "swiftgen-plugin",
  products: [
    .plugin(name: "SwiftGen - Generate", targets: ["SwiftGen - Generate"])
  ],
  targets: [
    .plugin(
      name: "SwiftGen - Generate",
      capability: .command(
        intent: .custom(
          verb: "swiftgen-generate",
          description: "Generate code based on swiftgen.yml"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Assets source code generation")
        ]
      ),
      path: "Plugins/SwiftGenPlugin"
    )
  ]
)
