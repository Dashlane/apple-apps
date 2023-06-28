import PackageDescription

let package = Package(
    name: "CoreSettings",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "CoreSettings",
            targets: ["CoreSettings"])
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/SwiftTreats")
    ],
    targets: [
                        .target(name: "CoreSettings",
                dependencies: [
                    .product(name: "DashTypes", package: "DashTypes"),
                    .product(name: "SwiftTreats", package: "SwiftTreats")
                ],
                resources: [
                    .process("Resources"),
                    .process("GeneratedClasses/SettingsDataModel.momd")
                ]
        ),
        .testTarget(
            name: "CoreSettingsTests",
            dependencies: ["CoreSettings"],
            resources: [
                .process("TestModel.xcdatamodeld"),
                .process("GeneratedClasses/TestModel.momd")
            ]
        )
    ]
)
