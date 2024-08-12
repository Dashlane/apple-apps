import PackageDescription

let package = Package(
  name: "AppleWebAuthn",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "WebAuthn",
      targets: ["WebAuthn"])
  ],
  dependencies: [
    .package(url: "_", from: "0.4.6")
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
