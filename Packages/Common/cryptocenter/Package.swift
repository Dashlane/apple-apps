import PackageDescription

let package = Package(
  name: "DashlaneCrypto",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v6)
    ],
  products: [
    .library(name: "DashlaneCrypto", targets: ["DashlaneCrypto"]),
    .library(name: "PasswordFormatterForKWC3", targets: ["PasswordFormatterForKWC3"]),
  ],
  dependencies: [
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DashTypes"),
    .package(path: "../../Foundation/TOTPGenerator")
  ],
  targets: [
    .target(name: "PasswordFormatterForKWC3"),
    .target(name: "DashlaneCrypto",
            dependencies: [
                "PasswordFormatterForKWC3",
                .product(name: "Argon2", package: "CyrilKit"),
                "TOTPGenerator",
                "DashTypes"
            ]),
    .testTarget(name: "DashlaneCryptoTests",
                dependencies: ["DashlaneCrypto"],
                exclude: ["Resources/cryptotests/package.json",
                          "Resources/cryptotests/README.md",
                          "Resources/cryptotests/Resources"],
                resources: [
                    .process("Resources/cryptotests/Tests/"),
                    .process("Resources/local/")
                ]),
    .testTarget(name: "DashlaneCryptoPerformanceTests",
                dependencies: ["DashlaneCrypto"])
  ]
)
