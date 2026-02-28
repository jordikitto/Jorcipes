// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesDesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "JorcipesDesignSystem", targets: ["JorcipesDesignSystem"])
    ],
    targets: [
        .target(
            name: "JorcipesDesignSystem",
            resources: [.process("Resources")]
        )
    ]
)
