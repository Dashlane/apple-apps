import PackageDescription

let package = Package(
    name: "CoreCrypto",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "CoreCrypto",
            targets: ["CoreCrypto"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/CyrilKit"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(url: "_", from: "0.9.1"),
        .package(url: "_", from: "0.4.5")
                    ],
    targets: [
                        .target(
            name: "CoreCrypto",
            dependencies: [.product(name: "Sodium", package: "swift-sodium"),
                           .product(name: "Argon2", package: "CyrilKit"),
                           .product(name: "SwiftTreats", package: "SwiftTreats")]),
        .testTarget(
            name: "CoreCryptoTests",
            dependencies: ["CoreCrypto",
                           .product(name: "Argon2", package: "CyrilKit"),
                           .product(name: "CyrilKit", package: "CyrilKit"),
                           .product(name: "SwiftCBOR", package: "SwiftCBOR"),
                           .product(name: "DashTypes", package: "DashTypes")
            ],
            resources: [.process("Resources")]),
    ]
)
