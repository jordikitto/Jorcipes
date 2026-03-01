# Update 1 Design

## General Changes

### Background colors
Apply `.background(.recipeBackground)` to each tab's root view.

### Rename ContentView
`ContentView` -> `RootTabView`. Update reference in `JorcipesApp.swift`.

### Remove CLAUDE.md comments
Strip any code comments referencing CLAUDE.md from all Swift files.

### Dev Tab
- New `DevSettingsView` in the main app target (not a package).
- `Picker` listing the 4 JSON filenames: `recipes_5`, `recipes_50`, `recipes_empty`, `recipes_corrupted`.
- Selection stored via `@AppStorage("mockDataSource")` with default `recipes_5`.
- On selection change, show a banner at the bottom stating "Restart the app for this to take effect."
- `MockAPIClient` gains an initializer parameter for the JSON filename. Read from `UserDefaults` at launch in `JorcipesApp`.
- Tab placed after Recipes, before Search: `Tab("Dev", systemImage: "hammer")`.

## List View

### DietaryBadgesView
- New view in `JorcipesCards` alongside existing `DietaryBadgeView`.
- Takes `[DietaryAttribute]`, sorts alphabetically in the initializer.
- Uses `ViewThatFits` to try `HStack` first, falling back to `VStack` when badges don't fit.
- Renders each attribute using existing `DietaryBadgeView`.

### Card layout change
- In `RecipeCardView`, move dietary badges above the title.
- Replace inline dietary badge rendering with `DietaryBadgesView`.

### Detail view layout change
- Dietary badges move above the title area (part of the broader detail redesign).

## Detail View Redesign

### Image header
Full-width placeholder at the top, same style as the card (rounded rectangle with fork/knife icon), scaled to fill width with a fixed aspect ratio.

### Title with toolbar behavior
Recipe title as large text below the image. When the title scrolls out of view, it appears in the navigation bar via `.navigationTitle` with inline display.

### Card-style layout (inside ScrollView)
1. Placeholder image (not in a card)
2. `DietaryBadgesView` (not in a card)
3. Title as large `Text` (not in a card)
4. Description + Servings in a card
5. "Ingredients" section header (not in a card)
6. All ingredients together in one card
7. "Instructions" section header (not in a card)
8. Each instruction step in its own card
   - Step 1 highlighted by default with an accent-colored border
   - Tapping any step makes it the highlighted one (in-memory `@State`)

### Card styling
Consistent material/surface background with design system corner radii and spacing.

## Search Overhaul

### Navigation title
Switch to `.navigationBarTitleDisplayMode(.inline)`.

### Search on submit only
Remove debounced `onChange` trigger. Search fires only on `.onSubmit(of: .search)`.

### New endpoint
- `APIClient` gains `func fetchFilterOptions() async throws -> FilterOptions`.
- `FilterOptions` model in `JorcipesCore`: `availableServings: [Int]` (sorted) and `availableIngredients: [String]` (sorted).
- `MockAPIClient` implements by loading JSON, extracting unique servings and ingredient names.
- Called once on search tab appear, cached in `SearchViewModel`.

### Filter UI - collapsed/expanded section
- `filtersExpanded: Bool` state in `SearchViewModel`.
- Collapsed: `"Filters (N)"` with chevron right. N is count of active filters (hidden when 0).
- Expanded: `"Filters (N)"` with chevron down, followed by filter rows.

### Filter rows (when expanded)
- `Dietary` — selected value or "Select"
- `Servings` — selected value (e.g. "2 servings") or "Select"
- `Included ingredients` — chips of selected items or "Select"
- `Excluded ingredients` — chips of selected items or "Select"
- Tapping any row's button opens a half-detent sheet (`.presentationDetents([.medium])`).

### Filter sheets
- **Dietary:** Buttons for each `DietaryAttribute`, multi-select, toggleable.
- **Servings:** Buttons for each available serving size, single-select.
- **Ingredients (included/excluded):** `List` with `.searchable`, focus on search bar when opened. Shows all available ingredients with select/deselect. Filtered by search text using `localizedStandardContains()`.

### On filter change
Closing a sheet triggers a new search automatically.

### Removed features
Current `SearchFilterView` with inline dietary chips, servings stepper, and ingredient chip input replaced entirely by the new filter system.
