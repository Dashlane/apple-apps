import PackageDescription

let package = Package(
    name: "IconLibrary",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
                .library(
            name: "IconLibrary",
            targets: ["IconLibrary"]),
    ],
    dependencies: [
                        .package(path: "../../Foundation/DashTypes")
    ],
    targets: [
                        .target(
            name: "IconLibrary",
            dependencies: [
                .product(name: "DashTypes", package: "DashTypes")
            ]),
        .testTarget(
            name: "IconLibraryTests",
            dependencies: ["IconLibrary"],
            resources: [
                .process("Resources/")
            ]),
    ]
)
