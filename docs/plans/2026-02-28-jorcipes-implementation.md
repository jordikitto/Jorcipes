# Jorcipes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a native iOS recipe browsing and searching app with mock API, adaptive grid, search filters, and MVVM architecture using local Swift packages.

**Architecture:** MVVM with container-based DI. Six local Swift packages (Core, DesignSystem, Networking, Cards, RecipeList, Search) composed in the app target via an `AppContainer`. Mock API simulates network requests with random delay.

**Tech Stack:** Swift 6.2, SwiftUI, iOS 26, Observation framework, Swift Testing

**Cross-Cutting Concerns (apply to ALL tasks with views):**
- **Accessibility:** Add `.accessibilityLabel()` and `.accessibilityHint()` to all custom interactive components (chips, cards, badges). Ensure all images have descriptive labels. Rely on Dynamic Type (no hardcoded font sizes per CLAUDE.md).
- **Localization-ready strings:** Use `String(localized:)` or `LocalizedStringKey` for all user-facing text (labels, button titles, section headers, ContentUnavailableView descriptions). This makes the app localization-ready without adding translations yet.

---

### Task 1: Create JorcipesCore Package

**Files:**
- Create: `Packages/JorcipesCore/Package.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/DietaryAttribute.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/Ingredient.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/Recipe.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/Loadable.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/RecipeSearchQuery.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/RecipeDestination.swift`
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/Recipe+Preview.swift`
- Test: `Packages/JorcipesCore/Tests/JorcipesCoreTests/RecipeTests.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
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
```

Note: macOS platform included to enable `swift test` during development.

**Step 2: Write the model types**

`DietaryAttribute.swift`:
```swift
public enum DietaryAttribute: String, Codable, CaseIterable, Sendable, Hashable {
    case vegetarian
    case vegan
}
```

`Ingredient.swift`:
```swift
public struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let quantity: String
    public let dietaryAttributes: Set<DietaryAttribute>

    public init(id: String, name: String, quantity: String, dietaryAttributes: Set<DietaryAttribute>) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.dietaryAttributes = dietaryAttributes
    }
}
```

`Recipe.swift`:
```swift
public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String
    public let servings: Int
    public let ingredients: [Ingredient]
    public let instructions: [String]

    public var dietaryAttributes: Set<DietaryAttribute> {
        guard !ingredients.isEmpty else { return [] }
        return DietaryAttribute.allCases.reduce(into: Set<DietaryAttribute>()) { result, attribute in
            if ingredients.allSatisfy({ $0.dietaryAttributes.contains(attribute) }) {
                result.insert(attribute)
            }
        }
    }

    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        servings: Int,
        ingredients: [Ingredient],
        instructions: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, servings, ingredients, instructions
    }
}
```

`Loadable.swift`:
```swift
public enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    public var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
```

`RecipeSearchQuery.swift`:
```swift
public struct RecipeSearchQuery: Equatable, Sendable {
    public var text: String
    public var dietaryAttributes: Set<DietaryAttribute>
    public var servings: Int?
    public var includedIngredients: [String]
    public var excludedIngredients: [String]

    public init(
        text: String = "",
        dietaryAttributes: Set<DietaryAttribute> = [],
        servings: Int? = nil,
        includedIngredients: [String] = [],
        excludedIngredients: [String] = []
    ) {
        self.text = text
        self.dietaryAttributes = dietaryAttributes
        self.servings = servings
        self.includedIngredients = includedIngredients
        self.excludedIngredients = excludedIngredients
    }

    public var isEmpty: Bool {
        text.isEmpty && dietaryAttributes.isEmpty && servings == nil
            && includedIngredients.isEmpty && excludedIngredients.isEmpty
    }
}
```

`RecipeDestination.swift`:
```swift
public enum RecipeDestination: Hashable {
    case detail(Recipe)
}
```

**Step 3: Write preview helpers**

`Recipe+Preview.swift`:
```swift
public extension Recipe {
    static let preview = Recipe(
        title: "Classic Margherita Pizza",
        description: "A traditional Italian pizza with fresh mozzarella, basil, and tomato sauce.",
        servings: 4,
        ingredients: [
            Ingredient(id: "pizza-dough", name: "Pizza Dough", quantity: "1 ball", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "mozzarella", name: "Fresh Mozzarella", quantity: "200g", dietaryAttributes: [.vegetarian]),
            Ingredient(id: "san-marzano-tomatoes", name: "San Marzano Tomatoes", quantity: "1 can", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "fresh-basil", name: "Fresh Basil", quantity: "1 bunch", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "olive-oil", name: "Extra Virgin Olive Oil", quantity: "2 tbsp", dietaryAttributes: [.vegetarian, .vegan])
        ],
        instructions: [
            "**Preheat** the oven to 250°C (480°F) with a pizza stone or inverted baking sheet inside.",
            "Stretch the dough into a 12-inch round on a floured surface. Transfer to a piece of parchment paper.",
            "Crush the San Marzano tomatoes by hand and spread evenly over the dough, leaving a 1-inch border.",
            "Tear the mozzarella into pieces and distribute across the pizza. Drizzle with olive oil.",
            "Slide the pizza (on parchment) onto the hot stone. Bake for **8–10 minutes** until the crust is golden and cheese is bubbly.",
            "Top with *fresh basil leaves* and serve immediately."
        ]
    )

    static let previewList: [Recipe] = [
        .preview,
        Recipe(
            title: "Grilled Chicken Caesar Salad",
            description: "Crispy romaine lettuce topped with grilled chicken, parmesan, and creamy caesar dressing.",
            servings: 2,
            ingredients: [
                Ingredient(id: "chicken-breast", name: "Chicken Breast", quantity: "2 pieces", dietaryAttributes: []),
                Ingredient(id: "romaine-lettuce", name: "Romaine Lettuce", quantity: "1 head", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "parmesan", name: "Parmesan Cheese", quantity: "50g", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "croutons", name: "Croutons", quantity: "1 cup", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "caesar-dressing", name: "Caesar Dressing", quantity: "4 tbsp", dietaryAttributes: [.vegetarian])
            ],
            instructions: [
                "Season chicken breasts with salt, pepper, and a drizzle of olive oil.",
                "Grill over **medium-high heat** for 6–7 minutes per side until internal temperature reaches 74°C (165°F).",
                "Wash and chop the romaine lettuce into bite-sized pieces. Place in a large bowl.",
                "Slice the grilled chicken. Toss lettuce with caesar dressing, top with chicken, croutons, and *shaved parmesan*."
            ]
        ),
        Recipe(
            title: "Vegan Thai Green Curry",
            description: "A fragrant and creamy Thai curry made with tofu, coconut milk, and fresh vegetables.",
            servings: 4,
            ingredients: [
                Ingredient(id: "firm-tofu", name: "Firm Tofu", quantity: "400g", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "coconut-milk", name: "Coconut Milk", quantity: "1 can (400ml)", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "green-curry-paste", name: "Green Curry Paste", quantity: "3 tbsp", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "bell-peppers", name: "Bell Peppers", quantity: "2 mixed colors", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "jasmine-rice", name: "Jasmine Rice", quantity: "2 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "thai-basil", name: "Thai Basil", quantity: "1 handful", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: [
                "Press tofu for 15 minutes, then cut into 1-inch cubes.",
                "Heat a tablespoon of oil in a wok over **high heat**. Fry tofu until golden on all sides, about 5 minutes. Set aside.",
                "In the same wok, cook the curry paste for 1 minute until fragrant. Pour in coconut milk and stir to combine.",
                "Add sliced bell peppers and simmer for **5–7 minutes** until tender.",
                "Return tofu to the wok. Stir gently and cook for 2 more minutes.",
                "Serve over steamed jasmine rice, garnished with *fresh Thai basil*."
            ]
        ),
        Recipe(
            title: "Classic Beef Tacos",
            description: "Seasoned ground beef in crispy taco shells with fresh toppings and melted cheese.",
            servings: 6,
            ingredients: [
                Ingredient(id: "ground-beef", name: "Ground Beef", quantity: "500g", dietaryAttributes: []),
                Ingredient(id: "taco-shells", name: "Taco Shells", quantity: "12 shells", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "iceberg-lettuce", name: "Iceberg Lettuce", quantity: "1/2 head", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "tomato", name: "Tomato", quantity: "2 large", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "cheddar-cheese", name: "Cheddar Cheese", quantity: "1 cup shredded", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "sour-cream", name: "Sour Cream", quantity: "1/2 cup", dietaryAttributes: [.vegetarian])
            ],
            instructions: [
                "Brown the ground beef in a skillet over **medium-high heat**, breaking it apart as it cooks.",
                "Drain excess fat. Add taco seasoning and 1/4 cup of water. Simmer for **3–4 minutes** until thickened.",
                "Warm taco shells according to package directions.",
                "Shred lettuce and dice tomatoes. Set up a taco bar with all toppings.",
                "Fill each shell with seasoned beef, then top with lettuce, tomato, *shredded cheddar*, and a dollop of sour cream."
            ]
        ),
        Recipe(
            title: "Wild Mushroom Risotto",
            description: "Creamy Italian risotto made with a medley of wild mushrooms, butter, and parmesan.",
            servings: 3,
            ingredients: [
                Ingredient(id: "arborio-rice", name: "Arborio Rice", quantity: "1.5 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "mixed-mushrooms", name: "Mixed Wild Mushrooms", quantity: "300g", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "vegetable-broth", name: "Vegetable Broth", quantity: "4 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "butter", name: "Butter", quantity: "3 tbsp", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "parmesan-risotto", name: "Parmesan Cheese", quantity: "3/4 cup grated", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "yellow-onion", name: "Yellow Onion", quantity: "1 medium", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "garlic", name: "Garlic", quantity: "3 cloves", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: [
                "Heat vegetable broth in a saucepan and keep at a gentle simmer.",
                "In a large pan, melt 1 tbsp butter over **medium heat**. Sauté mushrooms until golden, about 5 minutes. Set aside.",
                "In the same pan, sauté diced onion and minced garlic in 1 tbsp butter until softened, about 3 minutes.",
                "Add arborio rice and stir for **1–2 minutes** until the grains are lightly toasted and translucent at the edges.",
                "Add broth one ladle at a time, stirring frequently. Wait until each addition is mostly absorbed before adding the next. This takes about **18–20 minutes**.",
                "When rice is *al dente* and creamy, remove from heat. Stir in remaining butter, parmesan, and the sautéed mushrooms. Season to taste."
            ]
        )
    ]
}
```

**Step 4: Write failing tests**

`RecipeTests.swift`:
```swift
import Testing
@testable import JorcipesCore

@Suite("Recipe Model Tests")
struct RecipeTests {

    // MARK: - Dietary Attribute Computation

    @Test("Recipe with all vegetarian ingredients is vegetarian")
    func allVegetarianIngredients() {
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "A", quantity: "1", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "b", name: "B", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(!recipe.dietaryAttributes.contains(.vegan))
    }

    @Test("Recipe with all vegan ingredients is both vegan and vegetarian")
    func allVeganIngredients() {
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "A", quantity: "1", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "b", name: "B", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(recipe.dietaryAttributes.contains(.vegan))
    }

    @Test("Recipe with mixed ingredients has no dietary attributes")
    func mixedIngredients() {
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "Chicken", quantity: "1", dietaryAttributes: []),
                Ingredient(id: "b", name: "Lettuce", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    @Test("Recipe with no ingredients has no dietary attributes")
    func emptyIngredients() {
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 1,
            ingredients: [],
            instructions: []
        )
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    // MARK: - Codable

    @Test("Recipe round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let original = Recipe.preview
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Recipe.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.ingredients.count == original.ingredients.count)
        #expect(decoded.dietaryAttributes == original.dietaryAttributes)
    }

    @Test("Ingredient round-trips through JSON")
    func ingredientCodable() throws {
        let original = Ingredient(id: "test", name: "Test", quantity: "1 cup", dietaryAttributes: [.vegetarian, .vegan])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Ingredient.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - RecipeSearchQuery

    @Test("Empty query reports isEmpty as true")
    func emptyQuery() {
        let query = RecipeSearchQuery()
        #expect(query.isEmpty)
    }

    @Test("Query with text is not empty")
    func queryWithText() {
        let query = RecipeSearchQuery(text: "pizza")
        #expect(!query.isEmpty)
    }

    @Test("Query with dietary attributes is not empty")
    func queryWithDietary() {
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])
        #expect(!query.isEmpty)
    }

    // MARK: - Preview Data

    @Test("Preview list contains expected dietary distribution")
    func previewDietaryDistribution() {
        let recipes = Recipe.previewList
        let vegetarian = recipes.filter { $0.dietaryAttributes.contains(.vegetarian) }
        let vegan = recipes.filter { $0.dietaryAttributes.contains(.vegan) }
        let neither = recipes.filter { $0.dietaryAttributes.isEmpty }

        #expect(vegetarian.count == 3) // Margherita, Thai Curry, Risotto
        #expect(vegan.count == 1)      // Thai Curry only
        #expect(neither.count == 2)    // Caesar, Beef Tacos
    }
}
```

**Step 5: Run tests to verify they pass**

Run: `swift test --package-path Packages/JorcipesCore 2>&1 | tail -20`

Expected: All tests pass.

**Step 6: Commit**

```bash
git add Packages/JorcipesCore
git commit -m "feat: add JorcipesCore package with models and tests"
```

---

### Task 2: Create JorcipesDesignSystem Package

**Files:**
- Create: `Packages/JorcipesDesignSystem/Package.swift`
- Create: `Packages/JorcipesDesignSystem/Sources/JorcipesDesignSystem/Spacing.swift`
- Create: `Packages/JorcipesDesignSystem/Sources/JorcipesDesignSystem/CornerRadii.swift`
- Create: `Packages/JorcipesDesignSystem/Sources/JorcipesDesignSystem/Colors.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JorcipesDesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "JorcipesDesignSystem", targets: ["JorcipesDesignSystem"])
    ],
    targets: [
        .target(name: "JorcipesDesignSystem")
    ]
)
```

**Step 2: Write design tokens**

`Spacing.swift`:
```swift
import SwiftUI

public extension CGFloat {
    /// 2pt
    static let space50: CGFloat = 2
    /// 4pt
    static let space100: CGFloat = 4
    /// 6pt
    static let space150: CGFloat = 6
    /// 8pt
    static let space200: CGFloat = 8
    /// 12pt
    static let space300: CGFloat = 12
    /// 16pt
    static let space400: CGFloat = 16
    /// 20pt
    static let space500: CGFloat = 20
    /// 24pt
    static let space600: CGFloat = 24
    /// 28pt
    static let space700: CGFloat = 28
    /// 32pt
    static let space800: CGFloat = 32
    /// 36pt
    static let space900: CGFloat = 36
    /// 40pt
    static let space1000: CGFloat = 40
}
```

`CornerRadii.swift`:
```swift
import SwiftUI

public extension CGFloat {
    /// 8pt corner radius
    static let cornerRadiusSmall: CGFloat = 8
    /// 12pt corner radius
    static let cornerRadiusMedium: CGFloat = 12
    /// 16pt corner radius
    static let cornerRadiusLarge: CGFloat = 16
}
```

`Colors.swift` — Use an asset catalog for proper light/dark mode support:

Create directory `Packages/JorcipesDesignSystem/Sources/JorcipesDesignSystem/Resources/Colors.xcassets/` with the following color sets:

`Colors.xcassets/Contents.json`:
```json
{
  "info": { "author": "xcode", "version": 1 }
}
```

`Colors.xcassets/RecipePrimary.colorset/Contents.json`:
```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.929", "green": "0.549", "blue": "0.141", "alpha": "1.000" }
      },
      "idiom": "universal"
    },
    {
      "appearances": [{ "appearance": "luminosity", "value": "dark" }],
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.969", "green": "0.651", "blue": "0.278", "alpha": "1.000" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

`Colors.xcassets/RecipeSecondary.colorset/Contents.json`:
```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.831", "green": "0.627", "blue": "0.290", "alpha": "1.000" }
      },
      "idiom": "universal"
    },
    {
      "appearances": [{ "appearance": "luminosity", "value": "dark" }],
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.878", "green": "0.722", "blue": "0.376", "alpha": "1.000" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

`Colors.xcassets/RecipeBackground.colorset/Contents.json`:
```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "red": "1.000", "green": "0.973", "blue": "0.941", "alpha": "1.000" }
      },
      "idiom": "universal"
    },
    {
      "appearances": [{ "appearance": "luminosity", "value": "dark" }],
      "color": {
        "color-space": "srgb",
        "components": { "red": "0.110", "green": "0.110", "blue": "0.118", "alpha": "1.000" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

Then the `Colors.swift` file:
```swift
import SwiftUI

public extension Color {
    /// Warm orange primary brand color
    static let recipePrimary = Color("RecipePrimary", bundle: .module)
    /// Amber secondary brand color
    static let recipeSecondary = Color("RecipeSecondary", bundle: .module)
    /// Warm off-white background
    static let recipeBackground = Color("RecipeBackground", bundle: .module)
}
```

Update `Package.swift` to include resources:
```swift
.target(
    name: "JorcipesDesignSystem",
    resources: [.process("Resources")]
)
```

**Step 3: Verify build**

Run: `swift build --package-path Packages/JorcipesDesignSystem 2>&1 | tail -5`

Expected: Build succeeds.

**Step 4: Commit**

```bash
git add Packages/JorcipesDesignSystem
git commit -m "feat: add JorcipesDesignSystem package with spacing, colors, and corner radii"
```

---

### Task 3: Create JorcipesNetworking Package

**Files:**
- Create: `Packages/JorcipesNetworking/Package.swift`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/APIClient.swift`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/RecipesResponse.swift`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/MockAPIClient.swift`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_empty.json`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_5.json`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_50.json`
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_corrupted.json`
- Test: `Packages/JorcipesNetworking/Tests/JorcipesNetworkingTests/MockAPIClientTests.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JorcipesNetworking",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "JorcipesNetworking", targets: ["JorcipesNetworking"])
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
        .testTarget(
            name: "JorcipesNetworkingTests",
            dependencies: ["JorcipesNetworking"]
        )
    ]
)
```

**Step 2: Write protocol and response type**

`APIClient.swift`:
```swift
import JorcipesCore

public protocol APIClient: Sendable {
    func fetchRecipes() async throws -> [Recipe]
    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe]
}
```

`RecipesResponse.swift`:
```swift
import JorcipesCore

struct RecipesResponse: Codable, Sendable {
    let recipes: [Recipe]
}
```

**Step 3: Create mock JSON files**

`recipes_empty.json`:
```json
{
  "recipes": []
}
```

`recipes_5.json` — Contains the 5 recipes matching `Recipe.previewList` from JorcipesCore. Write the full JSON structure with all 5 recipes (Margherita Pizza, Chicken Caesar, Thai Green Curry, Beef Tacos, Mushroom Risotto) with UUIDs, all fields, and markdown instructions. Each ingredient must have `id`, `name`, `quantity`, and `dietaryAttributes` array. Match the preview data exactly (same ingredient IDs, same dietary attributes).

`recipes_corrupted.json`:
```json
{
  "recipes": [
    {
      "id": "not-a-uuid",
      "title": 12345,
      "servings": "not-a-number"
    }
  ]
}
```

`recipes_50.json` — Generate 50 diverse recipes following the same JSON structure. Include a good mix of vegetarian, vegan, and non-vegetarian recipes. Use realistic recipe data.

**Step 4: Write MockAPIClient**

`MockAPIClient.swift`:
```swift
import Foundation
import JorcipesCore

public final class MockAPIClient: APIClient, @unchecked Sendable {
    private let jsonFileName: String
    private let bundle: Bundle
    private let simulateDelay: Bool

    public init(jsonFileName: String = "recipes_5", bundle: Bundle = .module, simulateDelay: Bool = true) {
        self.jsonFileName = jsonFileName
        self.bundle = bundle
        self.simulateDelay = simulateDelay
    }

    public func fetchRecipes() async throws -> [Recipe] {
        if simulateDelay {
            try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
        }
        return try await loadRecipes()
    }

    public func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {
        if simulateDelay {
            try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
        }

        let allRecipes = try await loadRecipes()

        guard !query.isEmpty else { return allRecipes }

        return allRecipes.filter { recipe in
            matchesText(recipe: recipe, text: query.text)
                && matchesDietary(recipe: recipe, attributes: query.dietaryAttributes)
                && matchesServings(recipe: recipe, servings: query.servings)
                && matchesIncludedIngredients(recipe: recipe, included: query.includedIngredients)
                && matchesExcludedIngredients(recipe: recipe, excluded: query.excludedIngredients)
        }
    }

    // MARK: - Private

    /// Loads and decodes recipes off the main actor to avoid UI hitching.
    private nonisolated func loadRecipes() async throws -> [Recipe] {
        let jsonFileName = self.jsonFileName
        let bundle = self.bundle
        guard let url = bundle.url(forResource: jsonFileName, withExtension: "json") else {
            throw APIError.fileNotFound(jsonFileName)
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(RecipesResponse.self, from: data)
        return response.recipes
    }

    private func matchesText(recipe: Recipe, text: String) -> Bool {
        guard !text.isEmpty else { return true }
        return recipe.title.localizedStandardContains(text)
            || recipe.description.localizedStandardContains(text)
            || recipe.instructions.contains { $0.localizedStandardContains(text) }
    }

    private func matchesDietary(recipe: Recipe, attributes: Set<DietaryAttribute>) -> Bool {
        guard !attributes.isEmpty else { return true }
        return attributes.isSubset(of: recipe.dietaryAttributes)
    }

    private func matchesServings(recipe: Recipe, servings: Int?) -> Bool {
        guard let servings else { return true }
        return recipe.servings == servings
    }

    private func matchesIncludedIngredients(recipe: Recipe, included: [String]) -> Bool {
        guard !included.isEmpty else { return true }
        return included.allSatisfy { term in
            recipe.ingredients.contains { $0.name.localizedStandardContains(term) }
        }
    }

    private func matchesExcludedIngredients(recipe: Recipe, excluded: [String]) -> Bool {
        guard !excluded.isEmpty else { return true }
        return !excluded.contains { term in
            recipe.ingredients.contains { $0.name.localizedStandardContains(term) }
        }
    }
}

public enum APIError: LocalizedError, Sendable {
    case fileNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            "Could not find resource file: \(name).json"
        }
    }
}
```

**Step 5: Write tests**

`MockAPIClientTests.swift`:
```swift
import Testing
@testable import JorcipesNetworking
import JorcipesCore

@Suite("MockAPIClient Tests")
struct MockAPIClientTests {

    private func makeClient(jsonFileName: String = "recipes_5") -> MockAPIClient {
        MockAPIClient(jsonFileName: jsonFileName, simulateDelay: false)
    }

    // MARK: - Fetch

    @Test("Fetching recipes loads all recipes from JSON")
    func fetchAll() async throws {
        let client = makeClient()
        let recipes = try await client.fetchRecipes()
        #expect(recipes.count == 5)
    }

    @Test("Fetching from empty JSON returns empty array")
    func fetchEmpty() async throws {
        let client = makeClient(jsonFileName: "recipes_empty")
        let recipes = try await client.fetchRecipes()
        #expect(recipes.isEmpty)
    }

    @Test("Fetching from corrupted JSON throws decoding error")
    func fetchCorrupted() async {
        let client = makeClient(jsonFileName: "recipes_corrupted")
        await #expect(throws: (any Error).self) {
            try await client.fetchRecipes()
        }
    }

    @Test("Fetching from missing file throws APIError.fileNotFound")
    func fetchMissing() async {
        let client = makeClient(jsonFileName: "nonexistent")
        await #expect(throws: APIError.self) {
            try await client.fetchRecipes()
        }
    }

    // MARK: - Search: Text

    @Test("Search by title text returns matching recipes")
    func searchByTitle() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(text: "pizza")
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("pizza") == true)
    }

    @Test("Search with empty query returns all recipes")
    func searchEmptyQuery() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery()
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 5)
    }

    // MARK: - Search: Dietary

    @Test("Search by vegetarian returns only vegetarian recipes")
    func searchVegetarian() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(dietaryAttributes: [.vegetarian])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegetarian) })
        #expect(results.count == 3) // Margherita, Thai Curry, Risotto
    }

    @Test("Search by vegan returns only vegan recipes")
    func searchVegan() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegan) })
        #expect(results.count == 1) // Thai Curry only
    }

    // MARK: - Search: Servings

    @Test("Search by servings returns matching recipes")
    func searchByServings() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(servings: 4)
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.servings == 4 })
    }

    // MARK: - Search: Ingredients

    @Test("Search with included ingredient returns recipes containing it")
    func searchIncludedIngredient() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(includedIngredients: ["chicken"])
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 1) // Caesar only
    }

    @Test("Search with excluded ingredient filters out recipes containing it")
    func searchExcludedIngredient() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(excludedIngredients: ["cheese", "parmesan"])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { recipe in
            !recipe.ingredients.contains { $0.name.localizedStandardContains("cheese") || $0.name.localizedStandardContains("parmesan") }
        })
    }

    // MARK: - Search: Combined Filters

    @Test("Search with multiple filters combines them with AND logic")
    func searchCombinedFilters() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(
            dietaryAttributes: [.vegetarian],
            servings: 4
        )
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy {
            $0.dietaryAttributes.contains(.vegetarian) && $0.servings == 4
        })
    }
}
```

**Step 6: Run tests**

Run: `swift test --package-path Packages/JorcipesNetworking 2>&1 | tail -20`

Expected: All tests pass.

**Step 7: Commit**

```bash
git add Packages/JorcipesNetworking
git commit -m "feat: add JorcipesNetworking package with MockAPIClient and tests"
```

---

### Task 4: Create JorcipesCards Package

**Files:**
- Create: `Packages/JorcipesCards/Package.swift`
- Create: `Packages/JorcipesCards/Sources/JorcipesCards/RecipeCardView.swift`
- Create: `Packages/JorcipesCards/Sources/JorcipesCards/DietaryBadgeView.swift`
- Create: `Packages/JorcipesCards/Sources/JorcipesCards/RecipeDetailView.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
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
        .target(name: "JorcipesCards", dependencies: ["JorcipesCore", "JorcipesDesignSystem"])
    ]
)
```

**Step 2: Write DietaryBadgeView**

`DietaryBadgeView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct DietaryBadgeView: View {
    let attribute: DietaryAttribute

    public init(attribute: DietaryAttribute) {
        self.attribute = attribute
    }

    public var body: some View {
        Text(label)
            .font(.caption2)
            .bold()
            .padding(.horizontal, .space200)
            .padding(.vertical, .space50)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }

    private var label: String {
        switch attribute {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        }
    }

    private var color: Color {
        switch attribute {
        case .vegetarian: .green
        case .vegan: .mint
        }
    }
}

#Preview {
    HStack {
        DietaryBadgeView(attribute: .vegetarian)
        DietaryBadgeView(attribute: .vegan)
    }
}
```

**Step 3: Write RecipeCardView**

`RecipeCardView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeCardView: View {
    let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            // Placeholder image area
            RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                .fill(Color.recipeSecondary.opacity(0.2))
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(Color.recipeSecondary)
                }

            VStack(alignment: .leading, spacing: .space100) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: .space200) {
                    Label("\(recipe.servings)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    ForEach(Array(recipe.dietaryAttributes).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { attribute in
                        DietaryBadgeView(attribute: attribute)
                    }
                }
            }
            .padding(.horizontal, .space200)
            .padding(.bottom, .space300)
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusLarge))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

#Preview {
    ScrollView {
        RecipeCardView(recipe: .preview)
            .padding()
    }
}
```

**Step 4: Write RecipeDetailView**

`RecipeDetailView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeDetailView: View {
    let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space400) {
                RecipeHeaderSection(recipe: recipe)
                RecipeDietarySection(attributes: recipe.dietaryAttributes)
                RecipeIngredientsSection(ingredients: recipe.ingredients)
                RecipeInstructionsSection(instructions: recipe.instructions)
            }
            .padding(.space400)
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sections (separate View structs per CLAUDE.md)

struct RecipeHeaderSection: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            Text(recipe.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Label("\(recipe.servings) servings", systemImage: "person.2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct RecipeDietarySection: View {
    let attributes: Set<DietaryAttribute>

    var body: some View {
        if !attributes.isEmpty {
            HStack(spacing: .space200) {
                ForEach(Array(attributes).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { attribute in
                    DietaryBadgeView(attribute: attribute)
                }
            }
        }
    }
}

struct RecipeIngredientsSection: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            Text("Ingredients")
                .font(.title2)
                .bold()

            ForEach(ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.quantity)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, .space100)
                Divider()
            }
        }
    }
}

struct RecipeInstructionsSection: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: .space300) {
            Text("Instructions")
                .font(.title2)
                .bold()

            ForEach(instructions.enumerated(), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: .space300) {
                    Text("\(index + 1)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.recipePrimary)
                        .frame(width: 30)

                    if let attributed = try? AttributedString(markdown: instruction) {
                        Text(attributed)
                            .font(.body)
                    } else {
                        Text(instruction)
                            .font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .preview)
    }
}
```

**Step 5: Verify build**

Run: `swift build --package-path Packages/JorcipesCards 2>&1 | tail -5`

Expected: Build succeeds.

**Step 6: Commit**

```bash
git add Packages/JorcipesCards
git commit -m "feat: add JorcipesCards package with RecipeCardView and RecipeDetailView"
```

---

### Task 5: Create JorcipesRecipeList Package

**Files:**
- Create: `Packages/JorcipesRecipeList/Package.swift`
- Create: `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListViewModel.swift`
- Create: `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListView.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
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
        ])
    ]
)
```

**Step 2: Write RecipeListViewModel**

`RecipeListViewModel.swift`:
```swift
import Foundation
import JorcipesCore
import JorcipesNetworking

@MainActor
@Observable
public final class RecipeListViewModel {
    public private(set) var state: Loadable<[Recipe]> = .idle
    public var navigationPath: [RecipeDestination] = []

    private let apiClient: APIClient
    private var loadTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func onAppear() {
        guard case .idle = state else { return }
        load()
    }

    public func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let recipes = try await apiClient.fetchRecipes()
                try Task.checkCancellation()
                state = .loaded(recipes)
            } catch is CancellationError {
                // Ignore cancellation
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    public func refresh() async {
        do {
            let recipes = try await apiClient.fetchRecipes()
            state = .loaded(recipes)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        loadTask?.cancel()
    }
}
```

**Step 3: Write RecipeListView**

`RecipeListView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesCards

public struct RecipeListView: View {
    @State private var viewModel: RecipeListViewModel
    @Namespace private var heroNamespace

    public init(viewModel: RecipeListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.navigationPath) {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear

                case .loading:
                    ProgressView("Loading recipes...")

                case .loaded(let recipes):
                    if recipes.isEmpty {
                        ContentUnavailableView(
                            "No Recipes",
                            systemImage: "fork.knife",
                            description: Text("There are no recipes available at the moment.")
                        )
                    } else {
                        RecipeGridContent(recipes: recipes, heroNamespace: heroNamespace)
                    }

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            viewModel.load()
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: RecipeDestination.self) { destination in
                switch destination {
                case .detail(let recipe):
                    RecipeDetailView(recipe: recipe)
                        .navigationTransition(.zoom(sourceID: recipe.id, in: heroNamespace))
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                viewModel.onAppear()
            }
        }
    }

}

/// Extracted View struct for the recipe grid (per CLAUDE.md: no computed view properties).
struct RecipeGridContent: View {
    let recipes: [Recipe]
    var heroNamespace: Namespace.ID

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: .space400) {
                ForEach(recipes) { recipe in
                    NavigationLink(value: RecipeDestination.detail(recipe)) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: recipe.id, in: heroNamespace)
                }
            }
            .padding(.space400)
        }
    }
}

#Preview {
    RecipeListView(
        viewModel: RecipeListViewModel(
            apiClient: MockAPIClient(simulateDelay: false)
        )
    )
}
```

**Step 4: Verify build**

Run: `swift build --package-path Packages/JorcipesRecipeList 2>&1 | tail -5`

Expected: Build succeeds (or at minimum, no source errors — platform mismatch on macOS is expected).

**Step 5: Commit**

```bash
git add Packages/JorcipesRecipeList
git commit -m "feat: add JorcipesRecipeList package with browse grid and detail navigation"
```

---

### Task 6: Create JorcipesSearch Package

**Files:**
- Create: `Packages/JorcipesSearch/Package.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchViewModel.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/DietaryChipView.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientChipInputView.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchFilterView.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchView.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
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
        ])
    ]
)
```

**Step 2: Write SearchViewModel**

`SearchViewModel.swift`:
```swift
import Foundation
import JorcipesCore
import JorcipesNetworking

@MainActor
@Observable
public final class SearchViewModel {
    public private(set) var results: Loadable<[Recipe]> = .idle
    public var query = RecipeSearchQuery()
    public var navigationPath: [RecipeDestination] = []
    public var ingredientInput: String = ""

    private let apiClient: APIClient
    private var searchTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func search() {
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = .idle
            return
        }

        results = .loading

        searchTask = Task {
            do {
                // Debounce: wait 300ms before executing search.
                // If the user types again, this task gets cancelled.
                try await Task.sleep(for: .milliseconds(300))

                let recipes = try await apiClient.searchRecipes(query: query)
                try Task.checkCancellation()
                results = .loaded(recipes)
            } catch is CancellationError {
                // Ignore cancellation
            } catch {
                results = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Dietary Attributes

    public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {
        if query.dietaryAttributes.contains(attribute) {
            query.dietaryAttributes.remove(attribute)
        } else {
            query.dietaryAttributes.insert(attribute)
        }
        search()
    }

    public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {
        query.dietaryAttributes.contains(attribute)
    }

    // MARK: - Servings

    public func setServings(_ servings: Int?) {
        query.servings = servings
        search()
    }

    // MARK: - Ingredient Chips

    public func addIncludedIngredient() {
        let trimmed = ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        query.includedIngredients.append(trimmed)
        ingredientInput = ""
        search()
    }

    public func toggleIngredientChip(at index: Int) {
        guard index < query.includedIngredients.count else { return }
        let ingredient = query.includedIngredients.remove(at: index)
        query.excludedIngredients.append(ingredient)
        search()
    }

    public func toggleExcludedIngredientChip(at index: Int) {
        guard index < query.excludedIngredients.count else { return }
        let ingredient = query.excludedIngredients.remove(at: index)
        query.includedIngredients.append(ingredient)
        search()
    }

    public func removeIncludedIngredient(at index: Int) {
        guard index < query.includedIngredients.count else { return }
        query.includedIngredients.remove(at: index)
        search()
    }

    public func removeExcludedIngredient(at index: Int) {
        guard index < query.excludedIngredients.count else { return }
        query.excludedIngredients.remove(at: index)
        search()
    }

    // MARK: - Navigation

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    // MARK: - Text Search

    public func updateSearchText(_ text: String) {
        query.text = text
        search()
    }

    deinit {
        searchTask?.cancel()
    }
}
```

**Step 3: Write DietaryChipView**

`DietaryChipView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct DietaryChipView: View {
    let attribute: DietaryAttribute
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, .space300)
                .padding(.vertical, .space200)
                .background(isActive ? Color.recipePrimary : Color(.secondarySystemBackground))
                .foregroundStyle(isActive ? .white : .primary)
                .clipShape(.capsule)
        }
    }

    private var label: String {
        switch attribute {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        }
    }
}

#Preview {
    HStack {
        DietaryChipView(attribute: .vegetarian, isActive: true, action: {})
        DietaryChipView(attribute: .vegan, isActive: false, action: {})
    }
}
```

**Step 4: Write IngredientChipInputView**

`IngredientChipInputView.swift`:
```swift
import SwiftUI
import JorcipesDesignSystem

struct IngredientChipInputView: View {
    @Binding var text: String
    let includedIngredients: [String]
    let excludedIngredients: [String]
    let onSubmit: () -> Void
    let onToggleIncluded: (Int) -> Void
    let onToggleExcluded: (Int) -> Void
    let onRemoveIncluded: (Int) -> Void
    let onRemoveExcluded: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            TextField("Add ingredient...", text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onSubmit)

            if !includedIngredients.isEmpty || !excludedIngredients.isEmpty {
                WrappingHStack(spacing: .space200) {
                    ForEach(includedIngredients.enumerated(), id: \.offset) { index, name in
                        chipView(name: name, isIncluded: true) {
                            onToggleIncluded(index)
                        } onRemove: {
                            onRemoveIncluded(index)
                        }
                    }

                    ForEach(excludedIngredients.enumerated(), id: \.offset) { index, name in
                        chipView(name: name, isIncluded: false) {
                            onToggleExcluded(index)
                        } onRemove: {
                            onRemoveExcluded(index)
                        }
                    }
                }
            }
        }
    }

    private func chipView(name: String, isIncluded: Bool, onTap: @escaping () -> Void, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: .space100) {
            Button(action: onTap) {
                Label(
                    name,
                    systemImage: isIncluded ? "checkmark" : "minus"
                )
                .font(.subheadline)
            }
            .accessibilityHint(isIncluded ? "Tap to exclude this ingredient" : "Tap to include this ingredient")
            Button("Remove ingredient", systemImage: "xmark", action: onRemove)
                .font(.caption)
                .labelStyle(.iconOnly)
        }
        .padding(.horizontal, .space300)
        .padding(.vertical, .space150)
        .background(isIncluded ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .foregroundStyle(isIncluded ? .green : .red)
        .clipShape(.capsule)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(isIncluded ? "included" : "excluded")")
    }
}

/// A simple wrapping horizontal stack using Layout protocol.
struct WrappingHStack: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
```

**Step 5: Write SearchFilterView**

`SearchFilterView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct SearchFilterView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .space400) {
            // Dietary chips (WrappingHStack for extensibility with future attributes)
            VStack(alignment: .leading, spacing: .space200) {
                Text("Dietary")
                    .font(.headline)

                WrappingHStack(spacing: .space200) {
                    ForEach(DietaryAttribute.allCases, id: \.self) { attribute in
                        DietaryChipView(
                            attribute: attribute,
                            isActive: viewModel.isDietaryAttributeActive(attribute)
                        ) {
                            viewModel.toggleDietaryAttribute(attribute)
                        }
                    }
                }
            }

            // Servings (toggle to enable, stepper to set value)
            VStack(alignment: .leading, spacing: .space200) {
                Text("Servings")
                    .font(.headline)

                Toggle("Filter by servings", isOn: Binding(
                    get: { viewModel.query.servings != nil },
                    set: { enabled in
                        viewModel.setServings(enabled ? 1 : nil)
                    }
                ))

                if let servings = viewModel.query.servings {
                    Stepper(
                        "\(servings) servings",
                        value: Binding(
                            get: { servings },
                            set: { viewModel.setServings($0) }
                        ),
                        in: 1...20
                    )
                }
            }

            // Ingredient chips
            VStack(alignment: .leading, spacing: .space200) {
                Text("Ingredients")
                    .font(.headline)

                IngredientChipInputView(
                    text: $viewModel.ingredientInput,
                    includedIngredients: viewModel.query.includedIngredients,
                    excludedIngredients: viewModel.query.excludedIngredients,
                    onSubmit: { viewModel.addIncludedIngredient() },
                    onToggleIncluded: { viewModel.toggleIngredientChip(at: $0) },
                    onToggleExcluded: { viewModel.toggleExcludedIngredientChip(at: $0) },
                    onRemoveIncluded: { viewModel.removeIncludedIngredient(at: $0) },
                    onRemoveExcluded: { viewModel.removeExcludedIngredient(at: $0) }
                )
            }
        }
        .padding(.space400)
    }
}
```

**Step 6: Write SearchView**

`SearchView.swift`:
```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesCards

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @Namespace private var heroNamespace

    public init(viewModel: SearchViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(spacing: .space400) {
                    SearchFilterView(viewModel: viewModel)

                    Divider()

                    SearchResultsContent(
                        results: viewModel.results,
                        heroNamespace: heroNamespace,
                        onRetry: { viewModel.search() }
                    )
                }
            }
            .navigationTitle("Search")
            .searchable(text: $viewModel.query.text, prompt: "Search recipes...")
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .onChange(of: viewModel.query.text) {
                viewModel.search()
            }
            .navigationDestination(for: RecipeDestination.self) { destination in
                switch destination {
                case .detail(let recipe):
                    RecipeDetailView(recipe: recipe)
                        .navigationTransition(.zoom(sourceID: recipe.id, in: heroNamespace))
                }
            }
        }
    }

}

/// Extracted View struct for search results (per CLAUDE.md: no computed view properties).
struct SearchResultsContent: View {
    let results: Loadable<[Recipe]>
    var heroNamespace: Namespace.ID
    let onRetry: () -> Void

    var body: some View {
        switch results {
        case .idle:
            ContentUnavailableView(
                "Search Recipes",
                systemImage: "magnifyingglass",
                description: Text("Use the filters above or type a search term to find recipes.")
            )

        case .loading:
            ProgressView("Searching...")
                .padding()

        case .loaded(let recipes):
            if recipes.isEmpty {
                ContentUnavailableView.search
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: .space400) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: RecipeDestination.detail(recipe)) {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: recipe.id, in: heroNamespace)
                    }
                }
                .padding(.horizontal, .space400)
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("Search Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: onRetry)
            }
        }
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            apiClient: MockAPIClient(simulateDelay: false)
        )
    )
}
```

**Step 7: Verify build**

Run: `swift build --package-path Packages/JorcipesSearch 2>&1 | tail -5`

Expected: Build succeeds (or expected platform mismatch on macOS).

**Step 8: Commit**

```bash
git add Packages/JorcipesSearch
git commit -m "feat: add JorcipesSearch package with filters, chips, and search UI"
```

---

### Task 7: Wire Packages Into App Target

**Files:**
- Create: `Jorcipes/AppContainer.swift`
- Modify: `Jorcipes/ContentView.swift`
- Modify: `Jorcipes/JorcipesApp.swift`
- Modify: `Jorcipes.xcodeproj/project.pbxproj` (add local package references)

**Step 1: Add local package references to Xcode project**

Read the `Jorcipes.xcodeproj/project.pbxproj` file. Add the following:

1. In the root project object's `packageReferences` array, add `XCLocalSwiftPackageReference` entries for each package:
   - `Packages/JorcipesCore`
   - `Packages/JorcipesDesignSystem`
   - `Packages/JorcipesNetworking`
   - `Packages/JorcipesCards`
   - `Packages/JorcipesRecipeList`
   - `Packages/JorcipesSearch`

2. In the app target's `packageProductDependencies`, add `XCSwiftPackageProductDependency` for each product:
   - `JorcipesCore`
   - `JorcipesDesignSystem`
   - `JorcipesNetworking`
   - `JorcipesCards`
   - `JorcipesRecipeList`
   - `JorcipesSearch`

3. Add each product dependency to the app target's frameworks build phase.

This step requires careful editing of the pbxproj file. Read the current file to understand the existing structure, generate unique 24-character hex IDs for each new entry, and insert them in the correct sections.

**Step 2: Write AppContainer**

`AppContainer.swift`:
```swift
import JorcipesCore
import JorcipesNetworking
import JorcipesRecipeList
import JorcipesSearch

@MainActor
final class AppContainer {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func makeRecipeListViewModel() -> RecipeListViewModel {
        RecipeListViewModel(apiClient: apiClient)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(apiClient: apiClient)
    }
}
```

**Step 3: Update JorcipesApp.swift**

```swift
import SwiftUI
import JorcipesNetworking

@main
struct JorcipesApp: App {
    private let container = AppContainer(apiClient: MockAPIClient())

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
```

**Step 4: Update ContentView.swift**

```swift
import SwiftUI
import JorcipesRecipeList
import JorcipesSearch

struct ContentView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                RecipeListView(viewModel: container.makeRecipeListViewModel())
            }

            Tab(role: .search) {
                SearchView(viewModel: container.makeSearchViewModel())
            }
        }
    }
}
```

**Step 5: Delete the old ContentView preview if present**

The old `ContentView_Previews` or `#Preview` block needs to be updated since `ContentView` now takes a `container` parameter:

```swift
#Preview {
    ContentView(container: AppContainer(apiClient: MockAPIClient(simulateDelay: false)))
}
```

**Step 6: Build the project**

Run: `xcodebuild build -project Jorcipes.xcodeproj -scheme Jorcipes -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20`

Expected: Build succeeds.

**Step 7: Commit**

```bash
git add Jorcipes/ Jorcipes.xcodeproj
git commit -m "feat: wire all packages into app target with TabView and AppContainer"
```

---

### Task 8: Write ViewModel Unit Tests

**Files:**
- Create: `JorcipesTests/Helpers/ControlledAPIClient.swift`
- Modify: `JorcipesTests/JorcipesTests.swift` (replace placeholder with real tests)

**Step 1: Write ControlledAPIClient test helper**

`ControlledAPIClient.swift`:
```swift
import JorcipesCore
import JorcipesNetworking

actor ControlledAPIClient: APIClient {
    private var fetchContinuations: [CheckedContinuation<[Recipe], Error>] = []
    private var searchContinuations: [CheckedContinuation<[Recipe], Error>] = []

    func fetchRecipes() async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            fetchContinuations.append(continuation)
        }
    }

    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            searchContinuations.append(continuation)
        }
    }

    func resolveFetch(with result: Result<[Recipe], Error>) {
        guard !fetchContinuations.isEmpty else { return }
        let continuation = fetchContinuations.removeFirst()
        continuation.resume(with: result)
    }

    func resolveSearch(with result: Result<[Recipe], Error>) {
        guard !searchContinuations.isEmpty else { return }
        let continuation = searchContinuations.removeFirst()
        continuation.resume(with: result)
    }
}
```

**Step 2: Write RecipeListViewModel tests**

Replace `JorcipesTests.swift` contents:
```swift
import Testing
@testable import JorcipesRecipeList
@testable import JorcipesSearch
import JorcipesCore
import JorcipesNetworking

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {
    @Test("Initial state is idle")
    func initialState() {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        #expect(vm.state == .idle)
    }

    @Test("onAppear triggers loading state")
    func onAppearLoading() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        vm.onAppear()
        #expect(vm.state == .loading)
    }

    @Test("Successful load transitions to loaded")
    func loadSuccess() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let expected = Recipe.previewList

        vm.load()
        await client.resolveFetch(with: .success(expected))
        await Task.yield()

        #expect(vm.state == .loaded(expected))
    }

    @Test("Failed load transitions to failed")
    func loadFailure() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)

        vm.load()
        await client.resolveFetch(with: .failure(TestError.offline))
        await Task.yield()

        if case .failed = vm.state {
            // expected
        } else {
            Issue.record("Expected failed state, got \(vm.state)")
        }
    }

    @Test("onAppear does not reload if already loaded")
    func onAppearNoReload() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let recipes = Recipe.previewList

        vm.load()
        await client.resolveFetch(with: .success(recipes))
        await Task.yield()

        vm.onAppear()
        // State should still be loaded, not loading
        #expect(vm.state == .loaded(recipes))
    }

    @Test("didTapRecipe appends to navigation path")
    func didTapRecipe() {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let recipe = Recipe.preview

        vm.didTapRecipe(recipe)
        #expect(vm.navigationPath.count == 1)
    }

    @Test("Load cancellation prevents stale overwrite")
    func loadCancellationPreventsStaleOverwrite() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        vm.load() // request A
        vm.load() // request B cancels A

        await client.resolveFetch(with: .success(stale))  // stale response for A
        await client.resolveFetch(with: .success(latest))  // response for B
        await Task.yield()
        await Task.yield()

        #expect(vm.state == .loaded(latest))
    }

    @Test("Refresh keeps existing data visible during fetch")
    func refreshKeepsData() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let initial = Recipe.previewList

        // Load initial data
        vm.load()
        await client.resolveFetch(with: .success(initial))
        await Task.yield()
        #expect(vm.state == .loaded(initial))

        // Start refresh — state should remain loaded (SwiftUI manages the spinner)
        async let _ = vm.refresh()
        #expect(vm.state == .loaded(initial))

        await client.resolveFetch(with: .success([Recipe.preview]))
        await Task.yield()
    }
}

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {
    @Test("Initial results state is idle")
    func initialState() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        #expect(vm.results == .idle)
    }

    @Test("Search with non-empty query triggers loading state")
    func searchLoading() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.text = "pizza"
        vm.search()
        #expect(vm.results == .loading)
    }

    @Test("Search with empty query resets to idle")
    func searchEmpty() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query = RecipeSearchQuery()
        vm.search()
        #expect(vm.results == .idle)
    }

    @Test("Successful search transitions to loaded")
    func searchSuccess() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.text = "test"
        let expected = [Recipe.preview]

        vm.search()
        await client.resolveSearch(with: .success(expected))
        await Task.yield()

        #expect(vm.results == .loaded(expected))
    }

    @Test("Toggle dietary attribute adds and removes it")
    func toggleDietary() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)

        vm.toggleDietaryAttribute(.vegetarian)
        #expect(vm.query.dietaryAttributes.contains(.vegetarian))

        vm.toggleDietaryAttribute(.vegetarian)
        #expect(!vm.query.dietaryAttributes.contains(.vegetarian))
    }

    @Test("Adding included ingredient clears input and adds to query")
    func addIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.ingredientInput = "  chicken  "

        vm.addIncludedIngredient()
        #expect(vm.query.includedIngredients == ["chicken"])
        #expect(vm.ingredientInput.isEmpty)
    }

    @Test("Toggle included ingredient moves it to excluded")
    func toggleIncludedToExcluded() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken"]

        vm.toggleIngredientChip(at: 0)
        #expect(vm.query.includedIngredients.isEmpty)
        #expect(vm.query.excludedIngredients == ["chicken"])
    }

    @Test("Toggle excluded ingredient moves it to included")
    func toggleExcludedToIncluded() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.excludedIngredients = ["chicken"]

        vm.toggleExcludedIngredientChip(at: 0)
        #expect(vm.query.excludedIngredients.isEmpty)
        #expect(vm.query.includedIngredients == ["chicken"])
    }

    @Test("Adding whitespace-only ingredient is ignored")
    func addWhitespaceIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.ingredientInput = "   "

        vm.addIncludedIngredient()
        #expect(vm.query.includedIngredients.isEmpty)
    }

    @Test("Toggle ingredient at out-of-bounds index is safe")
    func toggleOutOfBounds() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken"]

        vm.toggleIngredientChip(at: 5)
        #expect(vm.query.includedIngredients == ["chicken"])
    }

    @Test("Remove ingredient at valid index removes it")
    func removeIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken", "beef"]

        vm.removeIncludedIngredient(at: 0)
        #expect(vm.query.includedIngredients == ["beef"])
    }

    @Test("Search cancellation prevents stale overwrite")
    func searchCancellationPreventsStaleOverwrite() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        vm.query.text = "old"
        vm.search() // request A
        vm.query.text = "new"
        vm.search() // request B cancels A

        await client.resolveSearch(with: .success(stale))
        await client.resolveSearch(with: .success(latest))
        await Task.yield()
        await Task.yield()

        #expect(vm.results == .loaded(latest))
    }
}

private enum TestError: Error {
    case offline
}
```

**Step 3: Run tests**

Run: `xcodebuild test -project Jorcipes.xcodeproj -scheme Jorcipes -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -30`

Expected: All tests pass.

**Step 4: Commit**

```bash
git add JorcipesTests/
git commit -m "test: add ViewModel unit tests with ControlledAPIClient"
```

---

### Task 9: Generate recipes_50.json

**Files:**
- Create: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_50.json`

**Step 1: Generate 50 diverse recipes**

Write a JSON file containing 50 recipes with realistic data. Include a good mix:
- ~15 vegetarian recipes (all ingredients vegetarian, some not vegan)
- ~8 vegan recipes (all ingredients both vegetarian and vegan)
- ~27 non-vegetarian recipes (at least one ingredient with empty dietary attributes)

Each recipe must have:
- Unique UUID `id`
- Realistic `title`, `description`
- Sensible `servings` (1–8 range)
- 3–8 ingredients each with `id`, `name`, `quantity`, `dietaryAttributes`
- 3–6 markdown `instructions` with bold/italic formatting

Use diverse cuisines: Italian, Mexican, Thai, Indian, Japanese, American, French, Mediterranean, Korean, Middle Eastern.

**Step 2: Verify the JSON is valid**

Run: `python3 -c "import json; json.load(open('Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_50.json')); print('Valid JSON')"`

**Step 3: Verify the recipes_5 JSON matches preview data UUIDs**

The `recipes_5.json` file must have specific UUIDs that match what tests expect. Since `Recipe.preview` generates random UUIDs at runtime, the JSON file uses its own UUIDs. Verify the test for dietary distribution passes by running:

Run: `swift test --package-path Packages/JorcipesNetworking 2>&1 | tail -20`

**Step 4: Commit**

```bash
git add Packages/JorcipesNetworking/Sources/JorcipesNetworking/Resources/recipes_50.json
git commit -m "feat: add 50-recipe mock JSON dataset"
```

---

### Task 10: Write README.md

**Files:**
- Create: `README.md`

**Step 1: Write README**

Include the following sections:
- **Setup Instructions**: Clone, open in Xcode 26+, select iOS 26 simulator, build and run
- **Architecture Overview**: MVVM with container-based DI, 6 local Swift packages, mock API layer
- **Package Dependency Graph**: ASCII diagram from design doc
- **Key Design Decisions**:
  - Dietary attributes computed from ingredients (not stored)
  - Mock API simulates real network behavior with random delay
  - `Tab(role: .search)` for native search experience
  - Hero zoom transitions between grid cards and detail view
  - `ContentUnavailableView` for empty/error/no-results states
  - Container-based DI for clean separation and testability
- **Assumptions and Tradeoffs**:
  - No real API — mock data from bundled JSON
  - No image loading — placeholder icons used
  - Ingredient quantity as plain string (no measurement parsing)
  - No persistence or favorites
- **Known Limitations**:
  - No offline support
  - No localization (strings are localization-ready but no translations provided)
  - No image loading (placeholder icons used)

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with architecture overview and design decisions"
```

---

### Task 11: Final Build and Test Verification

**Step 1: Clean build**

Run: `xcodebuild clean build -project Jorcipes.xcodeproj -scheme Jorcipes -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -20`

Expected: Build succeeds with no errors or warnings.

**Step 2: Run all tests**

Run: `xcodebuild test -project Jorcipes.xcodeproj -scheme Jorcipes -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -30`

Expected: All tests pass.

**Step 3: Verify previews compile**

Run: `xcodebuild build -project Jorcipes.xcodeproj -scheme Jorcipes -destination 'platform=iOS Simulator,name=iPhone 16' BUILD_FOR_PREVIEWS=YES 2>&1 | tail -10`

Expected: Build for previews succeeds.

**Step 4: Fix any issues found, then commit**

```bash
git add -A
git commit -m "fix: resolve any build or test issues from final verification"
```
