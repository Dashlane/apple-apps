import PackageDescription

let package = Package(
    name: "VaultKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "VaultKit",
            targets: ["VaultKit"]),
    ],
    dependencies: [
        .package(path: "../../Common/dashlanereportkit"),
        .package(path: "../../Common/documentservices"),
        .package(path: "../../Core/CorePremium"),
        .package(path: "../../Core/CoreSession"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Core/CoreSharing"),
        .package(path: "../../Core/CoreSync"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Plugins/sourcery-plugin"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(path: "../../Core/IconLibrary"),
        .package(path: "../../Foundation/UIDelight"),
        .package(name: "DashlaneCrypto", path: "../../Common/cryptocenter"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking")
    ],
    targets: [
        .target(
            name: "VaultKit",
            dependencies: [
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "CoreSession", package: "CoreSession"),
                .product(name: "DashlaneReportKit", package: "DashlaneReportKit"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "DocumentServices", package: "DocumentServices"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "CoreLocalization", package: "CoreLocalization"),
                .product(name: "DashlaneCrypto", package: "DashlaneCrypto"),
                .product(name: "CorePremium", package: "CorePremium"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "CoreSync", package: "CoreSync"),
                .product(name: "CoreSharing", package: "CoreSharing"),
                .product(name: "IconLibrary", package: "IconLibrary"),
                .product(name: "UIDelight", package: "UIDelight")
            ],
            resources: [.process("Resources")]
        )
    ]
)
