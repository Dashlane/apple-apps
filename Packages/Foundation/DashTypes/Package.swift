import PackageDescription

let package = Package(
    name: "DashTypes",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "DashTypes", targets: ["DashTypes"]),
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
                    path: "DashTypesUnitTests"),
    ]
)
