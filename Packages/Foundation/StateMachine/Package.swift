import PackageDescription

let package = Package(
  name: "StateMachine",
  platforms: [.macOS(.v13), .iOS(.v15)],
  products: [
    .library(
      name: "StateMachine",
      targets: ["StateMachine"])
  ],
  targets: [
    .target(
      name: "StateMachine"),
    .testTarget(
      name: "StateMachineTests",
      dependencies: ["StateMachine"]),
  ]
)
