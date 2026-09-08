# iFind

A landscape hidden-object game for young kids, revived in Expo + React Native for VS Code-first development.

## Phase 0 branch

`revival/phase-0-expo-baseline`

The original SwiftUI project remains under `iFind_App/` as reference material. The active revival app lives at the repository root.

## Requirements

- Node.js 22.13 or newer
- Expo Go with SDK 57 support, or a compatible simulator/development build

## Run it

```bash
npm install
npm start
```

Then:

- Scan the QR code with Expo Go on a compatible physical device.
- Press `w` for a browser preview.
- Press `i` for iOS Simulator if Apple Simulator tooling is installed on the Mac.

## Phase 0 scope

The revival currently recreates the playable vertical slice:

Splash -> Dashboard -> Bookshelf -> Animals -> Page 1 -> hidden-object scene -> completion.

Phase 0 now also includes:

- Expo SDK 57 + React Native + TypeScript baseline
- reusable book/page/level content catalog
- persistent completed-level progress
- persistent parent settings
- working Reset Progress control
- automatic future page unlock logic when more playable levels are added
- parent math gate
- GitHub typecheck/Expo Doctor validation

Still deferred: StoreKit, actual music/audio behavior, timer enforcement, additional content packs, production legal links, and final polish.
