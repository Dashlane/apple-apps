import PackageDescription

let package = Package(
    name: "SecurityDashboard",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "SecurityDashboard",
            targets: ["SecurityDashboard", "SecurityDashboardUI"])
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Core/CoreNetworking")
    ],
    targets: [
                        .target(
            name: "SecurityDashboard",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes")
            ]
        ),
        .target(
            name: "SecurityDashboardUI",
            dependencies: []
        ),
        .testTarget(
            name: "SecurityDashboardTests",
            dependencies: [
                "SecurityDashboard",
                .product(name: "DashTypes", package: "DashTypes")
            ],
            exclude: [
                "Resources/common-unit-tests/CHANGELOG.md",
                "Resources/common-unit-tests/package-lock.json",
                "Resources/common-unit-tests/package.json",
                "Resources/common-unit-tests/README.md",
                "Resources/common-unit-tests/password-strength/README.md",
                "Resources/common-unit-tests/password-similarity/README.md"
            ],
            resources: [
                .process("Breaches/Resources"),
                .process("Resources/common-unit-tests/password-similarity/Tests"),
                .process("Resources/common-unit-tests/password-strength/Tests")
            ]
        ),
        .testTarget(
            name: "SecurityDashboardPerformanceTests",
            dependencies: [
                "SecurityDashboard"
            ]
        ),
        .testTarget(
            name: "SecurityDashboardIntegrationTests",
            dependencies: [
                "SecurityDashboard",
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CoreNetworking", package: "CoreNetworking")
            ]
        )
    ]
)
