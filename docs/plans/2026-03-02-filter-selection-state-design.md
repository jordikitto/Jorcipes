# Filter sheet selection state improvement

## Problem

Selected rows in filter sheets (Dietary, Servings, Ingredients) use a small tinted checkmark as the only selection indicator. On the iOS 26 Liquid Glass sheet background, this is nearly invisible.

## Design

Replace the trailing checkmark with a tinted row background highlight:

- **Selected rows:** `.listRowBackground(Color.accentColor.opacity(0.12))`
- **Unselected rows:** `.listRowBackground(nil)` (default glass appearance)
- **No checkmark** — the background alone signals selection

### Scope

- DietaryFilterSheet (multi-select)
- ServingsFilterSheet (single-select)
- IngredientFilterSheet (multi-select, disabled state unchanged)
- InstructionsFilterSheet — unaffected (text field, no list rows)

### IngredientRow special case

Disabled rows (ingredient in opposite list) keep their existing treatment: tertiary text + capsule badge, no background highlight. Only non-disabled selected rows get the tinted background.
