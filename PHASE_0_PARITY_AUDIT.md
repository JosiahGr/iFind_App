# iFind Phase 0 parity audit

This file records what was intentionally carried forward from the original 2023 Swift app and the 2025 SwiftUI rebuild, plus what should remain deferred.

## Preserved or improved

### Core child flow
Preserved in Expo:

Splash -> Dashboard -> Bookshelf -> Book -> Page -> hidden-object game -> completion.

### Hidden-object game
Preserved:
- ordered targets
- scene-space hit rectangles
- correct / incorrect feedback
- star progression
- completion overlay
- replay / continue

The Expo version keeps the level definition data-driven rather than embedding level data in the book screen.

### Parent gate
Preserved:
- simple addition/subtraction prompt
- numeric answer buttons
- gate before settings and purchase controls

### Settings
The old Swift settings screen exposed Music, Sound Effects, and a 15 minute timer, but included a TODO to save state.

The Expo version now persists all three preferences locally with AsyncStorage. Actual audio playback and timer enforcement remain deferred.

### Reset Progress
The 2023 app included a dedicated two-step confirmation screen, but the final delete flag was not connected to actual progress deletion.

The Expo version now performs real progress deletion behind the parent gate. A separate second confirmation screen can be restored later if desired.

### Progress
The revived app now saves completed level IDs locally and renders completed pages after relaunch. Future playable pages automatically become available when the prior playable page is completed.

## Intentionally not ported yet

### StoreKit
Purchase and restore controls existed as UI/TODO scaffolding in both Swift generations. No production purchase state is being invented during Phase 0.

### Audio
Music and SFX preferences are stored, but no audio assets/playback system has been reintroduced yet.

### Timer
The 15 minute timer preference is stored, but enforcement is deferred until the desired parent experience is defined.

### Additional books/pages
Only the existing Animals vertical slice has verified playable content. Placeholder pages remain non-playable rather than duplicating the same scene and pretending they are finished content.

### Release/legal polish
Production Terms, Privacy, App Store purchase copy, analytics, and release-build behavior remain outside Phase 0.

## Legacy code worth keeping as reference

Do not delete either Swift repository yet. They still provide useful visual/product reference for:
- ResetProgressView confirmation UX
- purchase/settings layouts
- locked-book presentation
- original navigation and animation intent
- any old PageView behavior not yet recreated

## Phase 0 exit criteria

Phase 0 is ready to close when:
1. SDK 57 boots cleanly on the current Expo Go client.
2. TypeScript typecheck and Expo Doctor pass.
3. Animals Page 1 can be completed end-to-end.
4. Completion persists after app relaunch.
5. Reset Progress clears saved completion.
6. Parent preferences persist after relaunch.

After that, new work should move into Phase 1 rather than continuing to expand the migration baseline.
