import PackageDescription

let package = Package(
  name: "DashlaneAutofillKit",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "DashlaneAutofillKit",
      targets: ["DashlaneAutofillKit"])
  ],
  dependencies: [
    .package(path: "../Packages/Foundation/CyrilKit"),
    .package(path: "../Packages/Foundation/AppleWebAuthn"),
    .package(path: "../Packages/Foundation/LogFoundation"),
    .package(path: "../Foundation/SwiftUILottie"),
    .package(path: "../Packages/Feature/VaultKit"),
    .package(name: "CoreCategorizer", path: "../Packages/Core/CoreCategorizer"),
    .package(name: "CoreFeature", path: "../Packages/Core/CoreFeature"),
    .package(path: "../Packages/Core/CoreKeychain"),
    .package(path: "../Packages/Core/CorePasswords"),
    .package(path: "../Packages/Core/CoreSync"),
    .package(path: "../Packages/Core/CoreTypes"),
    .package(path: "../Packages/Core/DesignSystem"),
    .package(path: "../Packages/Common/documentservices"),
    .package(url: "_", branch: "master"),
    .package(path: "../Packages/Core/IconLibrary"),
    .package(path: "../Packages/Core/Logger"),
    .package(path: "../Packages/Feature/LoginKit"),
    .package(path: "../Packages/Core/UIComponents"),
    .package(path: "../Packages/Feature/NotificationKit"),
    .package(path: "../Packages/Core/CorePremium"),
    .package(path: "../Packages/Feature/PremiumKit"),
    .package(path: "../Packages/Foundation/SwiftTreats"),
    .package(path: "../Packages/Foundation/UIDelight"),
    .package(path: "../Packages/Plugins/sourcery-plugin"),
    .package(path: "../Packages/Plugins/swiftgen-plugin"),
  ],
  targets: [
    .target(
      name: "DashlaneAutofillKit",
      dependencies: [
        .product(name: "Argon2", package: "CyrilKit"),
        .product(name: "WebAuthn", package: "AppleWebAuthn"),
        .product(name: "SwiftUILottie", package: "SwiftUILottie"),
        .product(name: "VaultKit", package: "VaultKit"),
        .product(name: "AutofillKit", package: "VaultKit"),
        .product(name: "CoreCategorizer", package: "CoreCategorizer"),
        .product(name: "CoreFeature", package: "CoreFeature"),
        .product(name: "CoreKeychain", package: "CoreKeychain"),
        .product(name: "CorePasswords", package: "CorePasswords"),
        .product(name: "CoreSync", package: "CoreSync"),
        .product(name: "CoreTypes", package: "CoreTypes"),
        .product(name: "DesignSystem", package: "DesignSystem"),
        .product(name: "DocumentServices", package: "DocumentServices"),
        .product(name: "DomainParser", package: "swiftdomainparser"),
        .product(name: "IconLibrary", package: "IconLibrary"),
        .product(name: "Logger", package: "Logger"),
        .product(name: "LoginKit", package: "LoginKit"),
        .product(name: "UIComponents", package: "UIComponents"),
        .product(name: "NotificationKit", package: "NotificationKit"),
        .product(name: "CorePremium", package: "CorePremium"),
        .product(name: "PremiumKit", package: "PremiumKit"),
        .product(name: "SwiftTreats", package: "SwiftTreats"),
        .product(name: "UIDelight", package: "UIDelight"),
        .product(name: "LogFoundation", package: "LogFoundation"),
      ],
      resources: [.process("Resources")])
  ]
)
