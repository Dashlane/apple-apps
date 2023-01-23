import PackageDescription

let package = Package(
    name: "CoreSettings",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "CoreSettings",
            targets: ["CoreSettings"]),
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes"),
    ],
    targets: [
                        .target(name: "CoreSettings",
                dependencies: [
                    .product(name: "DashTypes", package: "DashTypes")
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
        )
    ]
)
