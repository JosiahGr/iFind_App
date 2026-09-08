# iFind Phase 0 Revival

This branch migrates the playable iFind vertical slice from SwiftUI to Expo + React Native so development can happen in VS Code and the app can be previewed with Expo Go or an iOS simulator.

## Phase 0 goals
- Preserve the existing Swift project as reference material.
- Establish an Expo + TypeScript app at the repository root.
- Recreate the core flow: splash -> dashboard -> bookshelf -> Animals book -> hidden-object page.
- Keep the hidden-object scene data-driven so additional pages can be added without rewriting gameplay code.
- Defer persistence, StoreKit, audio, timers, and production polish until the new baseline is running cleanly.

The Swift/Xcode source remains untouched during Phase 0.
