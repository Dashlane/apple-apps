import PackageDescription

let package = Package(
    name: "LoginKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "LoginKit",
            targets: ["LoginKit"]),
        .library(
            name: "LoginKitUITestsTools",
            targets: ["LoginKitUITestsTools"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/UIComponents"),
        .package(path: "../../Core/CoreSession"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Common/cryptocenter"),
        .package(path: "../../Core/CoreSync"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Common/dashlanereportkit"),
        .package(path: "../../Core/CorePasswords"),
        .package(path: "../../Core/CoreKeychain"),
        .package(path: "../../Core/Logger"),
        .package(path: "../../Core/CoreNetworking"),
        .package(path: "../../Plugins/sourcery-plugin"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(path: "../../Core/CorePremium"),
        .package(path: "../../Core/CoreFeature"),
        .package(path: "../../Core/CoreSettings"),
        .package(path: "../../Core/CoreCrypto"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
        .package(url: "_", from: "0.4.5")
    ],
    targets: [
                        .target(
            name: "LoginKit",
            dependencies: [
                .product(name: "Logger", package: "Logger"),
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "DashlaneReportKit", package: "DashlaneReportKit"),
                .product(name: "CoreSession", package: "CoreSession"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "DashlaneCrypto", package: "cryptocenter"),
                .product(name: "CoreSync", package: "CoreSync"),
                .product(name: "CoreLocalization", package: "CoreLocalization"),
                .product(name: "CorePasswords", package: "CorePasswords"),
                .product(name: "CoreKeychain", package: "CoreKeychain"),
                .product(name: "CoreSettings", package: "CoreSettings"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "CoreNetworking", package: "CoreNetworking"),
                .product(name: "CorePremium", package: "CorePremium"),
                .product(name: "CoreFeature", package: "CoreFeature"),
                .product(name: "CoreCrypto", package: "CoreCrypto"),
                .product(name: "SwiftCBOR", package: "SwiftCBOR")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "LoginKitTests",
            dependencies: ["LoginKit"],
            resources: [.process("Resources")]),
        .target(name: "LoginKitUITestsTools",
                dependencies: [
                    "LoginKit",
                    .product(name: "SwiftTreats", package: "SwiftTreats"),
                    .product(name: "CoreSession", package: "CoreSession"),
                    .product(name: "CorePersonalData", package: "CorePersonalData"),
                    .product(name: "DashlaneCrypto", package: "cryptocenter"),
                    .product(name: "CoreSync", package: "CoreSync")
                ])
    ]
)
