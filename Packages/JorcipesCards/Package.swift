// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesCards",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "JorcipesCards", targets: ["JorcipesCards"])
    ],
    dependencies: [
        .package(path: "../JorcipesCore"),
        .package(path: "../JorcipesDesignSystem")
    ],
    targets: [
        .target(name: "JorcipesCards", dependencies: ["JorcipesCore", "JorcipesDesignSystem"]),
        .testTarget(name: "JorcipesCardsTests", dependencies: ["JorcipesCards"])
    ]
)
