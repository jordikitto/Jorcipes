# Update 2 Design

## Overview

Code quality pass covering naming, documentation, renaming MockAPIClient to LocalAPIClient, and modernising the test suite with Swift Testing conventions.

## Naming

Rename all variables 3 characters or fewer. Two instances exist:
- `vm` → `viewModel` (~35 occurrences in tests, 1 in FilterSectionView preview)
- `s` → `servings` (1 occurrence in FilterSectionView)

## MockAPIClient → LocalAPIClient

Rename the class, file, test file, and all references across 6 files:
- `MockAPIClient.swift` → `LocalAPIClient.swift`
- `MockAPIClientTests.swift` → `LocalAPIClientTests.swift`
- References in: JorcipesApp, RecipeListView preview, RootTabView preview, FilterSectionView previews, SearchView preview

## Documentation Comments

Add `///` doc comments to 22 undocumented public functions across:
- `RecipeListViewModel` (4 functions)
- `SearchViewModel` (17 functions, `onFilterSheetDismiss` already documented)
- `RecipeDetailViewModel` (2 functions)
- `LocalAPIClient` (3 functions)

Keep comments concise — one line of intent, not restating the signature.

## Test Restructuring

### File split

Split `JorcipesTests.swift` (3 suites) into separate files (1 suite each):
- `RecipeListViewModelTests.swift`
- `SearchViewModelTests.swift`
- `RecipeDetailViewModelTests.swift`

### Naming convention

Switch from `@Test("description") func camelCase()` to backtick syntax:
```swift
@Test func `onAppear triggers loading state`() async { ... }
```

### GIVEN/WHEN/THEN comments

Add as section markers within each test:
```swift
// GIVEN: View model initialised with controlled client
// WHEN: Load completes successfully
// THEN: State is loaded with expected recipes
```

### Flow test groupings

**RecipeListViewModelTests** (8 → 3 flows):
- `happy path loads and refreshes recipes` — idle → loading → loaded → no-reload on reappear → refresh keeps data
- `failed load and stale cancellation` — load failure → cancellation prevents stale overwrite
- `tapping recipe navigates to detail` — standalone

**SearchViewModelTests** (15 → 4 flows):
- `search flow from idle through loading to loaded` — idle → loading → success → empty query → cancellation
- `filter manipulation updates query state` — toggle dietary → filter count → clear instruction → toggle ingredients
- `filter options load and retry from failure` — load success → retry after failure
- `sheet dismiss triggers search only when query changed` — dismiss changed → dismiss unchanged

**RecipeDetailViewModelTests** (7 → 2 flows):
- `instruction step progression from start to finish` — initial → start → next → last → finish resets
- `selecting a step directly sets highlight` — select middle → select last

### Tests to remove

- `RecipeTests.codableRoundTrip` — tests Apple's Codable synthesis, not our code
- `RecipeTests.ingredientCodable` — same
- `RecipeTests.previewDietaryDistribution` — tests preview data, fragile if data changes

### Tests to keep (rename only)

- `RecipeTests`: 4 dietary attribute computation tests + 3 RecipeSearchQuery isEmpty tests
- `LocalAPIClientTests`: All tests stay individual (integration tests against local JSON). Rename to backtick style, add GIVEN/WHEN/THEN.
