import PackageDescription

let package = Package(
    name: "CoreSync",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "CoreSync", targets: ["CoreSync"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/CyrilKit"),
        .package(path: "../../Core/CorePersonalData"),
        .package(name: "DashlaneCrypto", path: "../../Common/cryptocenter")
    ],
    targets: [
        .target(name: "CoreSync",
                dependencies: ["DashTypes", "CyrilKit"],
                path: "CoreSync"
        ),
        .testTarget(name: "CoreSyncTests",
                    dependencies: ["CoreSync", "DashlaneCrypto", "CorePersonalData"],
                    path: "CoreSyncTests",
                    resources: [
                        .process("Sync/Resources/")
                    ]
        )
    ]
)
