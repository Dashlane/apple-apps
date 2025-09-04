import PackageDescription

let package = Package(
  name: "CodableCSV",
  products: [
    .library(
      name: "CodableCSV",
      targets: ["CodableCSV"])
  ],
  targets: [
    .target(
      name: "CodableCSV"),
    .testTarget(
      name: "CodableCSVTests",
      dependencies: ["CodableCSV"]
    ),
  ]
)
