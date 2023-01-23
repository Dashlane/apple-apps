import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "Logger",
            targets: ["Logger"]),
    ],
    dependencies: [
                .package(path: "../../Foundation/DashTypes")
    ],
    targets: [
                        .target(
            name: "Logger",
            dependencies: ["DashTypes"]),
    ]
)
