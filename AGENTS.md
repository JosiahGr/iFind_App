# iFind agent guide

## Product

iFind is a landscape-first hidden-object game for young kids. The child chooses a themed book, opens a page, and finds objects in an illustrated scene one at a time.

## Current stack

- Expo SDK 57
- React Native 0.86
- React 19.2
- TypeScript
- AsyncStorage for local progress and preferences
- VS Code-first development
- Expo Go on a physical iPhone is the preferred preview path during revival

## Product rules

1. Keep the child-facing experience visual, simple, touch-friendly, and landscape-first.
2. Parent settings and purchases must stay behind a parental gate.
3. Hidden-object levels must be data-driven. Do not hard-code hit testing into screen components.
4. Preserve original iFind art whenever practical.
5. Do not delete the legacy Swift project during revival. It is reference material for behavior and assets.
6. Prefer small reusable components and plain React Native/Expo APIs before adding dependencies.
7. Progress and parent preferences must survive app relaunches.
8. Adding a new page should be primarily a content task. See `docs/CONTENT_AUTHORING.md`.

## Current phase

Phase 0 is complete. The active development branch is Phase 1: core experience.

Phase 1 priorities:
- improve game feel and child feedback
- improve content-authoring ergonomics
- preserve and clarify progress/unlock behavior
- clean up oversized screen code as features stabilize
- keep StoreKit, accounts, analytics, and release polish out until the core experience is solid

## Validation

Before considering a change ready:

```bash
npm run typecheck
npm run doctor
```

The app should run from the repository root with `npm install` then `npm start`.
