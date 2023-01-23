import PackageDescription

let package = Package(
    name: "CoreLocalization",
    defaultLocalization: "en",
    products: [
                .library(
            name: "CoreLocalization",
            targets: ["CoreLocalization"]),
    ],
    dependencies: [
        .package(path: "../../Plugins/swiftgen-plugin")
    ],
    targets: [
        .target(
              name: "CoreLocalization",
              dependencies: [],
              exclude: ["Resources/swiftgen.yml"],
              resources: [.process("Resources")]
        )
    ]
)
