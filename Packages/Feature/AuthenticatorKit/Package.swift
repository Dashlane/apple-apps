import PackageDescription

let package = Package(
    name: "AuthenticatorKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "AuthenticatorKit",
            targets: ["AuthenticatorKit"])
    ],
    dependencies: [
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Core/CoreIPC"),
        .package(name: "CoreCategorizer", path: "../../Core/CoreCategorizer"),
        .package(path: "../../Common/cryptocenter"),
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Core/CorePersonalData"),
        .package(path: "../../Core/CoreLocalization"),
        .package(path: "../../Core/CoreSync"),
        .package(path: "../../Core/CoreNetworking"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking"),
        .package(path: "../../Plugins/sourcery-plugin"),
        .package(path: "../../Plugins/swiftgen-plugin"),
        .package(name: "CoreSession", path: "../../Core/CoreSession"),
        .package(name: "CoreKeychain", path: "../../Core/CoreKeychain"),
        .package(name: "IconLibrary", path: "../../Core/IconLibrary"),
        .package(path: "../../Core/UIComponents"),
        .package(url: "_", .branch("master"))
    ],
    targets: [
                        .target(
            name: "AuthenticatorKit",
            dependencies: [
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "CoreIPC", package: "CoreIPC"),
                .product(name: "DashlaneCrypto", package: "cryptocenter"),
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "CoreLocalization", package: "CoreLocalization"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking"),
                .product(name: "CoreCategorizer", package: "CoreCategorizer"),
                .product(name: "CoreSession", package: "CoreSession"),
                .product(name: "CoreKeychain", package: "CoreKeychain"),
                .product(name: "DomainParser", package: "swiftdomainparser"),
                .product(name: "IconLibrary", package: "IconLibrary"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "CoreSync", package: "CoreSync"),
                .product(name: "CoreNetworking", package: "CoreNetworking")
            ],
            resources: [
                .process("Resources/")
            ]),
        .testTarget(
            name: "AuthenticatorKitTests",
            dependencies: ["AuthenticatorKit"])

    ]
)
