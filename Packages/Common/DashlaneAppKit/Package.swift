import PackageDescription

let package = Package(
    name: "DashlaneAppKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "DashlaneAppKit",
            targets: ["DashlaneAppKit"])
    ],
    dependencies: [
                .package(path: "../../Foundation/DashTypes"),
        .package(name: "DashlaneCrypto", path: "../cryptocenter"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(name: "CoreSettings", path: "../../Core/CoreSettings"),
        .package(name: "CoreFeature", path: "../Core/CoreFeature"),
        .package(name: "CoreSession", path: "../../Core/CoreSession"),
        .package(name: "CoreKeychain", path: "../../Core/CoreKeychain"),
        .package(name: "CoreSync", path: "../../Core/CoreSync"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
        .package(name: "CoreNetworking", path: "../../Core/CoreNetworking"),
        .package(name: "CoreCategorizer", path: "../../Core/CoreCategorizer"),
        .package(name: "CorePremium", path: "../../Core/CorePremium"),
        .package(name: "CorePersonalData", path: "../../Core/CorePersonalData"),
        .package(name: "IconLibrary", path: "../../Core/IconLibrary"),
        .package(path: "../../Core/Logger"),
        .package(url: "_", .branch("master")),
        .package(path: "../../Core/CoreRegion"),
        .package(path: "../../Feature/VaultKit")
    ],
    targets: [
                        .target(
            name: "DashlaneAppKit",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "IconLibrary", package: "IconLibrary"),
                .product(name: "DashlaneCrypto", package: "DashlaneCrypto"),
                .product(name: "CoreSettings", package: "CoreSettings"),
                .product(name: "CoreFeature", package: "CoreFeature"),
                .product(name: "CoreSession", package: "CoreSession"),
                .product(name: "CoreSync", package: "CoreSync"),
                .product(name: "CoreKeychain", package: "CoreKeychain"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "CoreNetworking", package: "CoreNetworking"),
                .product(name: "CoreCategorizer", package: "CoreCategorizer"),
                .product(name: "CorePremium", package: "CorePremium"),
                .product(name: "Logger", package: "Logger"),
                .product(name: "DomainParser", package: "swiftdomainparser"),
                .product(name: "CoreRegion", package: "CoreRegion"),
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "VaultKit", package: "VaultKit")
            ]
        )
    ]
)
