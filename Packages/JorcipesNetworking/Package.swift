// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesNetworking",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "JorcipesNetworking", targets: ["JorcipesNetworking"]),
        .library(name: "JorcipesTestSupport", targets: ["JorcipesTestSupport"])
    ],
    dependencies: [
        .package(path: "../JorcipesCore")
    ],
    targets: [
        .target(
            name: "JorcipesNetworking",
            dependencies: ["JorcipesCore"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "JorcipesTestSupport",
            dependencies: ["JorcipesCore", "JorcipesNetworking"]
        ),
        .testTarget(
            name: "JorcipesNetworkingTests",
            dependencies: ["JorcipesNetworking"]
        )
    ]
)
