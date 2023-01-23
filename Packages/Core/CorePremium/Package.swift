import PackageDescription

let package = Package(
    name: "CorePremium",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "CorePremium",
            targets: ["CorePremium"]),
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../CoreNetworking"),
    ],
    targets: [
                        .target(
            name: "CorePremium",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes")
            ]),
        .testTarget(
            name: "CorePremiumTests",
            dependencies: [
                "CorePremium",
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CoreNetworking", package: "CoreNetworking")
            ]
        )
    ]
)
