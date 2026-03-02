// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesSearch",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "JorcipesSearch", targets: ["JorcipesSearch"])
    ],
    dependencies: [
        .package(path: "../JorcipesCore"),
        .package(path: "../JorcipesDesignSystem"),
        .package(path: "../JorcipesCards"),
        .package(path: "../JorcipesNetworking")
    ],
    targets: [
        .target(name: "JorcipesSearch", dependencies: [
            "JorcipesCore", "JorcipesDesignSystem", "JorcipesCards", "JorcipesNetworking"
        ]),
        .testTarget(name: "JorcipesSearchTests", dependencies: [
            "JorcipesSearch",
            .product(name: "JorcipesTestSupport", package: "JorcipesNetworking")
        ])
    ]
)
