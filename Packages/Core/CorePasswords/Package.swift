import PackageDescription

let package = Package(
    name: "CorePasswords",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CorePasswords",
            targets: ["CorePasswords"]),
    ],
    dependencies: [
        .package(name: "DashTypes", path: "../../Foundation/DashTypes"),
    ],
    targets: [
        .target(
            name: "CorePasswords",
            dependencies: [
                "DashTypes",
            ],
            path: "CorePasswords",
            resources: [
                .process("version"),
                .process("Resource")
            ]
        ),
        .testTarget(
            name: "CorePasswordsTests",
            dependencies: [
                "CorePasswords"
            ],
            path: "CorePasswordsTests"
        )
    ]
)
