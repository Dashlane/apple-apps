import PackageDescription

let package = Package(
    name: "CorePasswords",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CorePasswords",
            targets: ["CorePasswords"])
    ],
    dependencies: [
        .package(name: "DashTypes", path: "../../Foundation/DashTypes"),
        .package(url: "_", branch: "main")
    ],
    targets: [
        .target(
            name: "CorePasswords",
            dependencies: [
                "DashTypes",
                .product(name: "ZXCVBN", package: "zxcvbnswift")

            ],
            resources: [
                .process("version"),
                .process("Resource")
            ]
        ),
        .testTarget(
            name: "CorePasswordsTests",
            dependencies: [
                "CorePasswords"
            ]
        ),
        .testTarget(
            name: "CorePasswordsPerformanceTests",
            dependencies: [
                "CorePasswords"
            ]
        )
    ]
)
