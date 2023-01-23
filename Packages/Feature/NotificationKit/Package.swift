import PackageDescription

let package = Package(
    name: "NotificationKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
                .library(
            name: "NotificationKit",
            targets: ["NotificationKit"]),
    ],
    dependencies: [
                .package(url: "_", from: "5.6.0"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Core/CoreNetworking"),
        .package(path: "../../Core/CoreSettings"),
        .package(path: "../../Foundation/UIDelight"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Plugins/sourcery-plugin"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(path: "../../Common/dashlanereportkit"),
        .package(path: "../../Core/CorePremium"),
        .package(path: "../../Core/CoreUserTracking"),
        .package(path: "../../Core/CoreFeature"),
        .package(path: "../../Core/UIComponents"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Core/CoreSession"),
    ],
    targets: [
                        .target(
            name: "NotificationKit",
            dependencies: [
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "BrazeUI", package: "braze-swift-sdk"),
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CoreNetworking", package: "CoreNetworking"),
                .product(name: "CoreSettings", package: "CoreSettings"),
                .product(name: "UIDelight", package: "UIDelight"),
                .product(name: "CoreLocalization", package: "CoreLocalization"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "DashlaneReportKit", package: "dashlanereportkit"),
                .product(name: "CorePremium", package: "CorePremium"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "CoreFeature", package: "CoreFeature"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "CoreSession", package: "CoreSession"),

            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "NotificationKitTests",
            dependencies: [
                "NotificationKit",
                .product(name: "BrazeKit", package: "braze-swift-sdk")
            ],
            resources: [.process("Resources")])
    ]
)
