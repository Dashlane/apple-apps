import PackageDescription

let package = Package(
    name: "DashTypes",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "DashTypes", targets: ["DashTypes"])
    ],
    dependencies: [
        .package(path: "../../Foundation/SwiftTreats")
    ],
    targets: [
        .target(name: "DashTypes",
                dependencies: [
                    .product(name: "SwiftTreats", package: "SwiftTreats")
                ],
                path: "DashTypes"
        ),
        .testTarget(name: "DashTypesTests",
                    dependencies: ["DashTypes"],
                    path: "DashTypesUnitTests")
    ]
)
