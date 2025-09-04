import PackageDescription

let package = Package(
  name: "StateMachine",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(
      name: "StateMachine",
      targets: ["StateMachine"]
    ),
    .library(
      name: "StateMachineTesting",
      targets: ["StateMachineTesting"]
    ),
  ],
  targets: [
    .target(
      name: "StateMachine"),
    .target(
      name: "StateMachineTesting",
      dependencies: [
        "StateMachine"
      ]
    ),
    .testTarget(
      name: "StateMachineTests",
      dependencies: ["StateMachine"]),
  ]
)
