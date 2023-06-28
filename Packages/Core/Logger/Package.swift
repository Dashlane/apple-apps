import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "Logger",
            targets: ["Logger"])
    ],
    dependencies: [
                .package(path: "../../Foundation/DashTypes")
    ],
    targets: [
                        .target(
            name: "Logger",
            dependencies: ["DashTypes"])
    ]
)
