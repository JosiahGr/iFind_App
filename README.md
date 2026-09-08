# iFind

A landscape hidden-object game for young kids, revived in Expo + React Native for VS Code-first development.

## Phase 0 branch

`revival/phase-0-expo-baseline`

The original SwiftUI project remains under `iFind_App/` as reference material. The active revival app now lives at the repository root.

## Run it

```bash
npm install
npm start
```

Then:

- Scan the QR code with Expo Go on a compatible physical device.
- Press `w` for a browser preview.
- Press `i` for iOS Simulator if Apple Simulator tooling is installed on the Mac.

Expo SDK 54 is intentional for this first revival pass because the current Expo transition guidance recommends SDK 54 when Expo Go on a physical iPhone is required.

## Phase 0 scope

The revival recreates the playable vertical slice:

Splash -> Dashboard -> Bookshelf -> Animals -> Page 1 -> hidden-object scene -> completion.

Not yet wired: persistent progress, StoreKit, production settings, audio, timers, or additional content packs.
