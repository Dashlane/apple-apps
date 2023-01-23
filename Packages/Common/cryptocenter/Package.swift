import PackageDescription

let package = Package(
  name: "DashlaneCrypto",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v6)
    ],
  products: [
    .library(name: "DashlaneCrypto", targets: ["DashlaneCrypto"]),
    .library(name: "PasswordFormatterForKWC3", targets: ["PasswordFormatterForKWC3"]),
    .library(name: "TOTPGenerator", targets: ["TOTPGenerator"]),
  ],
  dependencies: [
    .package(path: "../../Foundation/CyrilKit"),
    .package(path: "../../Foundation/DashTypes"),
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
    .target(name: "TOTPGenerator"),
    .testTarget(name: "DashlaneCryptoTests",
                dependencies: ["DashlaneCrypto"],
                exclude: ["Resources/cryptotests/package.json",
                          "Resources/cryptotests/README.md"],
                resources: [
                    .copy("Resources/cryptotests/Resources/"),
                    .process("Resources/cryptotests/Tests/"),
                    .process("Resources/local/")
                ]),
  ]
)

