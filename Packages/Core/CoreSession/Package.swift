import PackageDescription

let package = Package(
    name: "CoreSession",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CoreSession",
            targets: ["CoreSession"])
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/DashlaneAPI"),
        .package(path: "../../Foundation/CyrilKit"),
        .package(path: "../../Core/CoreNetworking")
    ],
    targets: [
        .target(
            name: "CoreSession",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "DashlaneAPI", package: "DashlaneAPI"),
                .product(name: "CyrilKit", package: "CyrilKit")
            ]
        ),
        .testTarget(
            name: "CoreSessionTests",
            dependencies: [
                "CoreSession",
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CoreNetworking", package: "CoreNetworking")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
