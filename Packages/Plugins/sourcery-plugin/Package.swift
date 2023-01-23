import PackageDescription

let package = Package(
  name: "sourcery-plugin",
  products: [
    .plugin(name: "Sourcery - Generate", targets: ["Sourcery - Generate"]),
  ],
  targets: [
    .plugin(
         name: "Sourcery - Generate",
         capability: .command(
           intent: .custom(
             verb: "sourcery-generate",
             description: "Generate code based on sourcery.yml"
           ),
           permissions: [
             .writeToPackageDirectory(reason: "Source code generation")
           ]
         ),
         path: "Plugins/SourceryPlugin"
       )
  ]
)
