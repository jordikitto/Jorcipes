// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JorcipesRecipeList",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "JorcipesRecipeList", targets: ["JorcipesRecipeList"])
    ],
    dependencies: [
        .package(path: "../JorcipesCore"),
        .package(path: "../JorcipesDesignSystem"),
        .package(path: "../JorcipesCards"),
        .package(path: "../JorcipesNetworking")
    ],
    targets: [
        .target(name: "JorcipesRecipeList", dependencies: [
            "JorcipesCore", "JorcipesDesignSystem", "JorcipesCards", "JorcipesNetworking"
        ]),
        .testTarget(name: "JorcipesRecipeListTests", dependencies: [
            "JorcipesRecipeList",
            .product(name: "JorcipesNetworkingTestSupport", package: "JorcipesNetworking")
        ])
    ]
)
