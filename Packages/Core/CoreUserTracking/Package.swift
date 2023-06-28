import PackageDescription

let package = Package(
    name: "CoreUserTracking",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
                .library(
            name: "CoreUserTracking",
            targets: ["CoreUserTracking"]
        )
    ],
    dependencies: [
                .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/DashlaneAPI")
    ],
    targets: [
                        .target(
            name: "CoreUserTracking",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "DashlaneAPI", package: "DashlaneAPI")
            ]
        ),
        .testTarget(name: "CoreUserTrackingTests", dependencies: ["CoreUserTracking"])
    ]
)
