// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesCore",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "JorcipesCore", targets: ["JorcipesCore"])
    ],
    targets: [
        .target(name: "JorcipesCore"),
        .testTarget(name: "JorcipesCoreTests", dependencies: ["JorcipesCore"])
    ]
)
