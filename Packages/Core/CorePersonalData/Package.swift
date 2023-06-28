import PackageDescription

let package = Package(
    name: "CorePersonalData",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
                .library(
            name: "CorePersonalData",
            targets: ["CorePersonalData"])
    ],
    dependencies: [
                .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/SwiftTreats"),
        .package(path: "../../Foundation/DatabaseFoundation"),
        .package(path: "../../Foundation/CyrilKit"),
        .package(url: "_", .branch("master"))
    ],
    targets: [
                        .target(
            name: "CorePersonalData",
            dependencies: [
                .product(name: "DatabaseFoundation", package: "DatabaseFoundation"),
                .product(name: "DashTypes", package: "DashTypes"),
                .product(name: "SwiftTreats", package: "SwiftTreats"),
                .product(name: "DomainParser", package: "swiftdomainparser"),
                .product(name: "CyrilKit", package: "CyrilKit")
            ]),
        .testTarget(
            name: "CorePersonalDataTests",
            dependencies: ["CorePersonalData"],
            exclude: [
                "DataModel/README.md",
                "DataModel/check.sh"
            ],
            resources: [
                .process("Resources"),
                .copy("DataModel/examples"),
                .copy("DataModel/meta"),
                .copy("DataModel/schemas")
            ])
    ]
)
