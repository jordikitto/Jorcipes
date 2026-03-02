# README Design

## Structure

Approach 1: Challenge deliverables first, development process last.

Primary headings match what the coding challenge PDF asks for.

## Sections

### 1. Header & Setup Instructions

- Title: "Jorcipes"
- One-line description referencing the ReciMe coding challenge
- Setup: open project, select iOS 26+ sim, build and run
- Note: no third-party dependencies

### 2. Architecture Overview

- MVVM with modular SPM packages
- Table of packages and responsibilities (Core, DesignSystem, Networking, Cards, RecipeList, Search)
- Key patterns: @Observable ViewModels, Loadable<T>, APIClient protocol, AppContainer, task-based cancellation

### 3. Key Design Decisions

- Native iOS look with warm ReciMe branding
- Adaptive grid layout (iPad support)
- Liquid Glass filter chips
- Consistent sheet-based filtering UX
- Step-by-step instruction rendering with markdown
- Computed dietary attributes (all ingredients must match)
- Card-style recipe presentation

### 4. Assumptions & Tradeoffs

- Native iOS UI over custom branding
- No persistence (not required by challenge)
- No real images (placeholder only)
- Client-side filtering (protocol ready for real backend)
- Dev settings tab for testing

### 5. Known Limitations

- Card disappearance on swipe-back (LazyVGrid)
- Filter animation glitches
- Hardcoded dietary attributes enum
- No localisation

### 6. Development Process

- Dedicated section about Claude Code usage
- Workflow: brainstorm -> plan -> implement -> review
- Reference Plan/ folder and update files as evidence of input
- My contributions: direction/taste, filter UX, manual edits, MVVM guidance, Xcode agent
- Tooling: Claude Code + Superpowers plugin, swiftui-expert skills, Xcode MCP

## Style

- Succinct and to the point
- No screenshots
- No emojis
- Text-only
