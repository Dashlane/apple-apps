import PackageDescription

let package = Package(
    name: "ImportKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CSVParser",
            targets: ["CSVParser"]),
        .library(
            name: "ImportKit",
            targets: ["ImportKit"])
    ],
    dependencies: [
        .package(path: "../../Common/DashlaneAppKit"),
        .package(path: "../../Core/CoreSession"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Core/UIComponents"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(path: "../LoginKit"),
        .package(path: "../VaultKit"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking")
    ],
    targets: [
        .target(
            name: "CSVParser",
            dependencies: []
        ),
        .target(
            name: "ImportKit",
            dependencies: [
                "CSVParser",
                .product(name: "CoreLocalization", package: "CoreLocalization"),
                .product(name: "DashlaneAppKit", package: "DashlaneAppKit"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "LoginKit", package: "LoginKit"),
                .product(name: "VaultKit", package: "VaultKit"),
                .product(name: "CoreSession", package: "CoreSession"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CSVParserTests",
            dependencies: ["CSVParser"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
