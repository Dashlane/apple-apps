import PackageDescription
import Darwin.C

var swiftSettings: [SwiftSetting] = []
if let envPointer = getenv("INTEGRATION_TEST") {
    let integrationTest = String(cString: envPointer)

    if !integrationTest.isEmpty {
        swiftSettings.append(.define("INTEGRATION_TEST"))
    }
}

let package = Package(
    name: "CoreNetworking",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "CoreNetworking", targets: ["CoreNetworking"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/DashTypes"),
        .package(path: "../../Foundation/DashlaneAPI"),
    ],
    targets: [
        .target(name: "CoreNetworking",
                dependencies: ["DashTypes", "DashlaneAPI"],
                path: "CoreNetworking",
                swiftSettings: swiftSettings),
        .testTarget(name: "CoreNetworkingTests",
                    dependencies: ["CoreNetworking"],
                    path: "CoreNetworkingTests",
                    resources: [
                        .process("TestResources/")
                    ]),
    ]
)
