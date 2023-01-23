import PackageDescription

let package = Package(
    name: "AuthenticatorKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "AuthenticatorKit",
            targets: ["AuthenticatorKit"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Core/CoreIPC"),
        .package(path: "../../Common/cryptocenter"),
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Core/CorePersonalData"),
        .package(name: "CoreUserTracking", path: "../../Core/CoreUserTracking")
    ],
    targets: [
                        .target(
            name: "AuthenticatorKit",
            dependencies: [
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "CoreIPC", package: "CoreIPC"),
                .product(name: "TOTPGenerator", package: "cryptocenter"),
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "CorePersonalData", package: "CorePersonalData"),
                .product(name: "CoreUserTracking", package: "CoreUserTracking")
            ],
            resources: [
                .process("Resources/")
            ]),
        .testTarget(
            name: "AuthenticatorKitTests",
            dependencies: ["AuthenticatorKit"]),
        
    ]
)


