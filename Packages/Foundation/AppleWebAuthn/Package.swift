import PackageDescription

let package = Package(
  name: "AppleWebAuthn",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "WebAuthn",
      targets: ["WebAuthn"])
  ],
  dependencies: [
    .package(url: "_", from: "0.5.0")
  ],
  targets: [
    .target(
      name: "WebAuthn",
      dependencies: [
        .product(name: "SwiftCBOR", package: "SwiftCBOR")
      ]
    ),
    .testTarget(
      name: "WebAuthnTests",
      dependencies: ["WebAuthn"]
    ),
  ]
)
