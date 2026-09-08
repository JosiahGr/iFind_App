# iFind content authoring

The revival is designed so a new hidden-object page is mostly a content task, not a gameplay-code task.

## What a page needs

A playable page needs:

1. A landscape scene image.
2. The scene's original pixel width and height.
3. An ordered list of targets.
4. A thumbnail for each target.
5. A normalized hit rectangle for each target.
6. A page entry in `src/data/catalog.ts`.

Gameplay itself lives in `src/components/SceneGame.tsx` and should not be duplicated per page.

## Normalized hit rectangles

Each target uses a rectangle with values from 0 to 1:

```ts
rect: {
  x: 0.23,
  y: 0.58,
  width: 0.132,
  height: 0.339,
}
```

These values are proportions of the original scene image, not device pixels. This lets the same level work on different screen sizes.

For an original scene that is 1664 x 768 pixels:

```text
normalized x = left pixel / 1664
normalized y = top pixel / 768
normalized width = target width in pixels / 1664
normalized height = target height in pixels / 768
```

Hit areas should be generous for young kids. They do not need to trace the artwork tightly.

## Add a level

Create a new `Level` in `src/data/levels.ts`:

```ts
export const exampleLevel: Level = {
  id: 'animals-2',
  title: 'Animals · Page 2',
  scene: require('../../assets/animals-page-2.png'),
  sceneWidth: 1664,
  sceneHeight: 768,
  targets: [
    {
      id: 'fox',
      label: 'Fox',
      thumbnail: require('../../assets/target-fox.png'),
      rect: { x: 0.1, y: 0.2, width: 0.14, height: 0.3 },
    },
  ],
};
```

Target order is the order the child will be asked to find objects.

## Add the page to a book

Import the level into `src/data/catalog.ts` and assign it to the appropriate page definition.

Once the prior playable page is completed, the existing progress logic automatically makes the next playable page available.

## Content rules

- Use stable IDs. Once released, do not casually rename level IDs because completion progress is stored by ID.
- Keep scenes landscape-first.
- Use large, forgiving hit areas.
- Target thumbnails should clearly match what the child is looking for.
- Avoid targets hidden entirely behind navigation, progress, or target-card UI.
- Test every target on a physical phone before considering a page complete.

## Future authoring tool

A later Phase 1/2 improvement should add a development-only hitbox editor so rectangles can be created visually instead of calculated by hand.
