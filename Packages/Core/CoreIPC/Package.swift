import PackageDescription

let package = Package(
    name: "CoreIPC",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CoreIPC",
            targets: ["CoreIPC"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Common/cryptocenter"),
        .package(path: "../../Core/CoreKeychain"),
    ],
    targets: [
        .target(
            name: "CoreIPC",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "DashlaneCrypto", package: "cryptocenter"),
                .product(name: "CoreKeychain", package: "CoreKeychain")
            ]),
        .testTarget(
            name: "CoreIPCTests",
            dependencies: ["CoreIPC",
                           .product(name: "DashTypes", package: "DashTypes"),
            ]
        ),
    ]
)
