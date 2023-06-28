import PackageDescription

let package = Package(
    name: "CoreFeature",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "CoreFeature", targets: ["CoreFeature"])
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Foundation/DashlaneAPI"),
        .package(path: "../../Core/CoreNetworking"),
        .package(path: "../../Core/CoreSession"),
        .package(path: "../../Foundation/CyrilKit")
    ],
    targets: [
        .target(name: "CoreFeature", dependencies: [
            .product(name: "DashTypes", package: "DashTypes"),
            .product(name: "SwiftTreats", package: "SwiftTreats"),
            .product(name: "CoreNetworking", package: "CoreNetworking"),
            .product(name: "CoreSession", package: "CoreSession"),
            .product(name: "Argon2", package: "CyrilKit"),
            .product(name: "DashlaneAPI", package: "DashlaneAPI")
        ]),
        .testTarget(name: "CoreFeatureTests", dependencies: [
            "CoreFeature",
            .product(name: "DashTypes", package: "DashTypes")
        ])
    ]
)
