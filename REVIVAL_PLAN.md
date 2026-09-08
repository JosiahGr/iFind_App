# iFind Phase 0 Revival

This branch migrates the playable iFind vertical slice from SwiftUI to Expo + React Native so development can happen in VS Code and the app can be previewed with Expo Go or an iOS simulator.

## Phase 0 goals
- Preserve the existing Swift project as reference material.
- Establish an Expo SDK 57 + TypeScript app at the repository root.
- Recreate the core flow: splash -> dashboard -> bookshelf -> Animals book -> hidden-object page.
- Keep books, pages, and levels data-driven so additional content can be added without rewriting gameplay code.
- Persist local progress and parent preferences.
- Restore Reset Progress behavior behind the parent gate.
- Add basic automated typechecking and Expo Doctor validation.

## Current status

Implemented:
- core six-target Animals level
- persistent completion state
- completed-page UI
- future sequential page-unlock rules
- persistent Music, Sound Effects, and Timer preferences
- working Reset Progress
- parent math gate
- Expo SDK 57 baseline for current Expo Go

Deferred until later phases:
- StoreKit purchase/restore
- actual music and sound playback
- timer enforcement
- additional books and unique page artwork
- production legal links
- release-build polish

The Swift/Xcode source remains untouched during Phase 0 and should be kept as reference until feature parity has been reviewed.
