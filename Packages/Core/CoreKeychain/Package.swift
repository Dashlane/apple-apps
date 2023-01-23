import PackageDescription

let package = Package(
    name: "CoreKeychain",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "CoreKeychain",
            targets: ["CoreKeychain"]),
    ],
    dependencies: [
                        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Foundation/DashTypes"),
    ],
    targets: [
                        .target(
            name: "CoreKeychain",
            dependencies: [
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "DashTypes", package: "DashTypes"),
            ],
            resources: [.process("Resources")]
        )
    ]
)
