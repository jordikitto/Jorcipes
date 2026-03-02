import SwiftUI

public extension Color {
    /// Warm orange primary brand color
    static let recipePrimary = Color("RecipePrimary", bundle: .module)
    /// Amber secondary brand color
    static let recipeSecondary = Color("RecipeSecondary", bundle: .module)
    /// Warm off-white background
    static let recipeBackground = Color("RecipeBackground", bundle: .module)
}

public extension ShapeStyle where Self == Color {
    /// Warm orange primary brand color
    static var recipePrimary: Color { .recipePrimary }
    /// Amber secondary brand color
    static var recipeSecondary: Color { .recipeSecondary }
    /// Warm off-white background
    static var recipeBackground: Color { .recipeBackground }
}
