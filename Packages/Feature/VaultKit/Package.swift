import PackageDescription

let package = Package(
    name: "VaultKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "VaultKit",
            targets: ["VaultKit"]),
        .library(
            name: "AutofillKit",
            targets: ["AutofillKit"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CyrilKit"),
        .package(name: "DashlaneCrypto", path: "../../Common/cryptocenter"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
        .package(name: "CoreActivityLogs", path: "../../Core/CoreActivityLogs"),
        .package(name: "CoreFeature", path: "../../Core/CoreFeature"),
        .package(name: "CoreCategorizer", path: "../../Core/CoreCategorizer"),
        .package(path: "../../Core/CorePremium"),
        .package(path: "../../Core/CoreSession"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Core/CoreSharing"),
        .package(path: "../../Core/CoreSync"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Core/CorePasswords"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/IconLibrary"),
        .package(path: "../../Core/UIComponents"),
        .package(path: "../../Core/CoreSettings"),
        .package(path: "../../Core/Logger"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/UIDelight"),
        .package(path: "../../Plugins/sourcery-plugin"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(path: "../../Common/documentservices")
    ],

    targets: [
        .target(
            name: "VaultKit",
            dependencies: [
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "CoreSession", package: "CoreSession"),
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
                .product(name: "UIDelight", package: "UIDelight"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "CoreActivityLogs", package: "CoreActivityLogs"),
                .product(name: "CoreFeature", package: "CoreFeature"),
                .product(name: "CoreSettings", package: "CoreSettings"),
                .product(name: "CoreCategorizer", package: "CoreCategorizer"),
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "Logger", package: "Logger"),
                .product(name: "CorePasswords", package: "CorePasswords")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "AutofillKit",
            dependencies: [
                "VaultKit",
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "Argon2", package: "CyrilKit"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "CoreSettings", package: "CoreSettings"),
                .product(name: "Logger", package: "Logger")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "VaultKitTests",
            dependencies: [
                "VaultKit",
                .product(name: "CorePersonalData", package: "CorePersonalData")
            ]
        ),
        .testTarget(
            name: "AutofillKitTests",
            dependencies: [
                "AutofillKit",
                .product(name: "CorePersonalData", package: "CorePersonalData")
            ]
        )
    ]
)
