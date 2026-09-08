# iFind agent guide

## Product

iFind is a landscape-first hidden-object game for young kids. The child chooses a themed book, opens a page, and finds objects in an illustrated scene one at a time.

## Current stack

- Expo SDK 54
- React Native
- React
- TypeScript
- VS Code-first development
- Expo Go on a physical iPhone is the preferred zero-Xcode preview path during Phase 0.

## Product rules

1. Keep the child-facing experience visual, simple, touch-friendly, and landscape-first.
2. Parent settings and purchases must stay behind a parental gate.
3. Hidden-object levels must be data-driven. Do not hard-code hit testing into screen components.
4. Preserve original iFind art whenever practical.
5. Do not delete the legacy Swift project during revival. It is reference material for behavior and assets.
6. Phase 0 is about a clean playable baseline, not StoreKit, accounts, analytics, or production polish.
7. Prefer small reusable components and plain React Native APIs before adding dependencies.

## Phase 0 definition of done

Splash -> Dashboard -> Bookshelf -> Animals -> Page 1 -> playable six-target hidden-object level -> completion state.

The app should run from the repository root with `npm install` then `npm start`.
