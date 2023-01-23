import PackageDescription

let package = Package(
    name: "Documentations",
    products: [
                .library(
            name: "Documentations",
            targets: ["Documentations"])
    ],
    dependencies: [
                .package(url: "_", from: "1.0.0"),
    ],
    targets: [
                        .target(
            name: "Documentations",
            dependencies: [])
    ] 
)
