import PackageDescription

let package = Package(
    name: "CoreIPC",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CoreIPC",
            targets: ["CoreIPC"])
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes")
    ],
    targets: [
        .target(
            name: "CoreIPC",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes")
            ]),
        .testTarget(
            name: "CoreIPCTests",
            dependencies: ["CoreIPC",
                           .product(name: "DashTypes", package: "DashTypes")
            ]
        ),
        .testTarget(
            name: "CoreIPCPerformanceTests",
            dependencies: ["CoreIPC"]
        )
    ]
)
