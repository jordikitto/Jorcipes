# README Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a README.md at the repo root that satisfies the ReciMe coding challenge deliverables.

**Architecture:** Single markdown file with six sections matching the approved design at `docs/plans/2026-03-02-readme-design.md`. Challenge-required headings first, development process section last.

**Tech Stack:** Markdown

---

### Task 1: Write README.md

**Files:**
- Create: `README.md`

**Step 1: Write the full README**

Create `README.md` at the repo root with the following content. Each section's content was approved during the brainstorming session — reproduce it faithfully.

```markdown
# Jorcipes

A native iOS recipe browsing and search app, built with Swift and SwiftUI for the ReciMe coding challenge.

## Setup Instructions

1. Open `Jorcipes.xcodeproj` in Xcode 26.3 or later
2. Select an iOS 26+ simulator or device
3. Build and run (⌘R)

No third-party dependencies — the project uses only Swift Package Manager for internal modularisation.

## Architecture Overview

The app follows MVVM with a modular package structure:

| Package | Responsibility |
|---|---|
| **JorcipesCore** | Models (`Recipe`, `Ingredient`, `DietaryAttribute`), query types, shared state (`Loadable<T>`) |
| **JorcipesDesignSystem** | Colour palette, spacing, and corner radius tokens |
| **JorcipesNetworking** | `APIClient` protocol and `LocalAPIClient` mock implementation |
| **JorcipesCards** | Shared UI — recipe cards, grid layout, detail view |
| **JorcipesRecipeList** | Browse tab — recipe list with pull-to-refresh |
| **JorcipesSearch** | Search tab — text search with dietary, servings, ingredient, and instruction filters |

### Key patterns

- **`@Observable` ViewModels** — `@MainActor` classes drive each screen's state
- **`Loadable<T>`** — An enum (`idle | loading | loaded | failed`) manages async state transitions
- **`APIClient` protocol** — Abstracts data access; `LocalAPIClient` loads bundled JSON with simulated latency, making it trivial to swap in a real backend
- **`AppContainer`** — A lightweight dependency container injected at the app root
- **Task-based cancellation** — Search requests are debounced and cancelled on new input

## Key Design Decisions

- **Native iOS look with warm branding** — The UI follows standard iOS conventions (NavigationStack, search tab, Dynamic Type) with subtle ReciMe-inspired orange/amber accent colours to add warmth.
- **Adaptive grid layout** — Recipes display in a LazyVGrid that adapts column count to available width, providing natural iPad support.
- **Liquid Glass filters** — Filter chips use glassEffect styling on iOS 26, giving the search interface a modern, tactile feel.
- **Consistent filtering UX** — All filters (dietary, servings, ingredients, instructions) use a uniform sheet-based interaction pattern for discoverability and consistency.
- **Step-by-step instructions** — The detail view renders cooking instructions as a numbered step list with markdown support, rather than a wall of text.
- **Computed dietary attributes** — A recipe is only classified as vegetarian/vegan if *all* its ingredients carry that attribute, ensuring accuracy.
- **Card-style recipe presentation** — Each recipe appears as a card with title, description, servings, and dietary badges for quick scanning.

## Assumptions & Tradeoffs

- **UI leans into native iOS** — The interface prioritises platform-native patterns over a custom-branded look. This feels polished and familiar, but some may prefer a more distinctive visual identity.
- **No persistence** — Recipes are fetched fresh each launch. There's no favouriting, bookmarking, or offline caching, as the challenge focuses on browsing and search.
- **No real images** — Recipes use system placeholder images. In production, an image URL field and async image loading would be added to the model.
- **Client-side filtering** — The `LocalAPIClient` performs all search and filtering in-memory. The `APIClient` protocol is designed so a real backend could handle this server-side with no view changes.
- **Dev settings tab** — A developer-only tab allows switching between mock data sources (5 recipes, 50 recipes, empty, corrupted) for quick testing during development.

## Known Limitations

- **Card disappearance on swipe-back** — Occasionally, recipe cards disappear when navigating back from the detail view. This appears related to LazyVGrid recycling behaviour.
- **Filter animation glitches** — The expand/collapse animation on filter sections can be slightly choppy under certain conditions.
- **Hardcoded dietary attributes** — Vegetarian and vegan are defined as a Swift enum. In production, these could be driven by the API to support additional attributes without an app update.
- **No localisation** — Strings are not externalised into .xcstrings files. The app is English-only.

## Development Process

This project was built with [Claude Code](https://claude.ai/claude-code) as a development partner. I wanted to be transparent about what was me versus the machine.

### Workflow

Each feature followed a structured cycle: **brainstorm → plan → implement → review**. The `Plan/` folder contains the prompts and planning documents that drove each stage, including:

- `ReciMe iOS Coding Challenge Plan.md` — my initial prompt to Claude Code
- `Update 1.md`, `Update 2.md`, `Update 3.md` — iterative refinement prompts covering UI, UX, implementation quality, and coding style
- `docs/plans/` — design documents and implementation plans produced during brainstorming sessions

### My contributions

- **Direction and taste** — I drove all UI/UX decisions, architecture choices, and quality standards through detailed prompts and iterative review
- **Filter UX** — The filtering interaction design required significant effort to make it look good, feel intuitive, and work reliably
- **Manual edits** — I made direct code changes alongside Claude-generated output
- **MVVM guidance** — I provided an `mvvm.md` reference to align Claude with the MVVM pattern, since I primarily use The Composable Architecture at work
- **Xcode 26.3 coding agent** — I also used the new Xcode MCP integration for some changes

### Tooling

- Claude Code with the **Superpowers** plugin (brainstorming → planning → implementation workflow)
- **swiftui-expert** skills for SwiftUI best practices
- Xcode MCP server for build/test integration
```

**Step 2: Verify the file renders correctly**

Skim the written file to check for markdown formatting issues (broken tables, mismatched backticks, etc.).

**Step 3: Commit**

```bash
git add README.md
git commit -m "Add README for ReciMe coding challenge"
```
