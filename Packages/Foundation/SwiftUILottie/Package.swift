import PackageDescription

let package = Package(
  name: "SwiftUILottie",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "SwiftUILottie",
      targets: ["SwiftUILottie"])
  ],
  dependencies: [
    .package(url: "_", from: "4.5.0")
  ],
  targets: [
    .target(
      name: "SwiftUILottie",
      dependencies: [
        .product(name: "Lottie", package: "lottie-ios")
      ]
    )
  ]
)
