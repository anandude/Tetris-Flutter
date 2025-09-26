# Implementation Plan

## Phase 1 · Project Foundation
- Review `pubspec.yaml` dependencies and add game-logic helpers (e.g., `provider`) if needed.
- Sketch initial state/data models for the board, tetromino shapes, and game status.
- Define development conventions: folder layout under `lib/`, state management approach, and testing strategy.

## Phase 2 · Core Game Loop
- Implement board/grid representation and rendering pipeline.
- Create tetromino models, rotation logic, random generator, and spawning rules.
- Build gravity/drop loop with timers or `Ticker`.
- Handle user input (tap/keyboard/gesture) for move, rotate, hard drop.
- Add collision detection and wall kicks for rotations.

## Phase 3 · Game Rules & Progression
- Detect and clear completed lines; manage combo/score multipliers.
- Track level progression, speed increases, and game-over detection.
- Persist best score locally (e.g., `shared_preferences`).

## Phase 4 · UI & UX Polish
- Design main layout (board, next-piece preview, score panel) with responsive sizing.
- Add animations for line clears, piece landing, and game-over overlay.
- Implement settings/pause menu, sound effects toggle, and haptic feedback if applicable.

## Phase 5 · Testing & Quality
- Write unit tests for shape logic, collision handling, and line clears.
- Add widget tests for key screens/widgets.
- Run `flutter analyze` and fix lint issues; ensure builds for iOS, Android, web, and desktop succeed.

## Phase 6 · Deployment Prep
- Optimize assets, sounds, and fonts.
- Update `README.md` with build instructions and screenshots.
- Configure app icons, splash screens, and platform-specific settings.
- Plan release steps (store listings, versioning, test builds).

