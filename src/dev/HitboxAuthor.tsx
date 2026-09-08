import React, { useMemo, useState } from 'react';
import {
  Image,
  LayoutChangeEvent,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import type { Level } from '../data/levels';

type Props = {
  level: Level;
  onExit: () => void;
};

type Size = { width: number; height: number };
type Point = { x: number; y: number };
type Rect = { x: number; y: number; width: number; height: number };

function clamp(value: number, min = 0, max = 1) {
  return Math.min(max, Math.max(min, value));
}

function imageGeometry(container: Size, level: Level) {
  const scale = Math.max(
    container.width / level.sceneWidth,
    container.height / level.sceneHeight,
  );

  const width = level.sceneWidth * scale;
  const height = level.sceneHeight * scale;

  return {
    scale,
    width,
    height,
    offsetX: (container.width - width) / 2,
    offsetY: (container.height - height) / 2,
  };
}

function viewPointToNormalized(point: Point, container: Size, level: Level): Point {
  const geometry = imageGeometry(container, level);

  return {
    x: clamp((point.x - geometry.offsetX) / geometry.width),
    y: clamp((point.y - geometry.offsetY) / geometry.height),
  };
}

function normalizedRectToView(rect: Rect, container: Size, level: Level): Rect {
  const geometry = imageGeometry(container, level);

  return {
    x: geometry.offsetX + rect.x * geometry.width,
    y: geometry.offsetY + rect.y * geometry.height,
    width: rect.width * geometry.width,
    height: rect.height * geometry.height,
  };
}

function rectFromPoints(start: Point, end: Point, container: Size, level: Level): Rect {
  const a = viewPointToNormalized(start, container, level);
  const b = viewPointToNormalized(end, container, level);

  return {
    x: Math.min(a.x, b.x),
    y: Math.min(a.y, b.y),
    width: Math.abs(b.x - a.x),
    height: Math.abs(b.y - a.y),
  };
}

function round(value: number) {
  return Number(value.toFixed(4));
}

function rectCode(rect: Rect) {
  return `rect: { x: ${round(rect.x)}, y: ${round(rect.y)}, width: ${round(rect.width)}, height: ${round(rect.height)} },`;
}

export function HitboxAuthor({ level, onExit }: Props) {
  const [size, setSize] = useState<Size>({ width: 1, height: 1 });
  const [dragStart, setDragStart] = useState<Point | null>(null);
  const [dragEnd, setDragEnd] = useState<Point | null>(null);
  const [draftRect, setDraftRect] = useState<Rect | null>(null);

  const liveRect = useMemo(() => {
    if (!dragStart || !dragEnd) return null;
    return rectFromPoints(dragStart, dragEnd, size, level);
  }, [dragEnd, dragStart, level, size]);

  function handleLayout(event: LayoutChangeEvent) {
    const { width, height } = event.nativeEvent.layout;
    setSize({ width, height });
  }

  return (
    <View style={styles.root} onLayout={handleLayout}>
      <Image source={level.scene} style={styles.scene} resizeMode="cover" />

      {level.targets.map((target) => {
        const rect = normalizedRectToView(target.rect, size, level);
        return (
          <View
            key={target.id}
            pointerEvents="none"
            style={[
              styles.existingRect,
              { left: rect.x, top: rect.y, width: rect.width, height: rect.height },
            ]}
          >
            <Text style={styles.existingLabel}>{target.label}</Text>
          </View>
        );
      })}

      {liveRect || draftRect ? (() => {
        const rect = normalizedRectToView(liveRect ?? draftRect!, size, level);
        return (
          <View
            pointerEvents="none"
            style={[
              styles.draftRect,
              { left: rect.x, top: rect.y, width: rect.width, height: rect.height },
            ]}
          />
        );
      })() : null}

      <View
        style={StyleSheet.absoluteFill}
        onStartShouldSetResponder={() => true}
        onMoveShouldSetResponder={() => true}
        onResponderGrant={(event) => {
          const point = {
            x: event.nativeEvent.locationX,
            y: event.nativeEvent.locationY,
          };
          setDragStart(point);
          setDragEnd(point);
        }}
        onResponderMove={(event) => {
          setDragEnd({
            x: event.nativeEvent.locationX,
            y: event.nativeEvent.locationY,
          });
        }}
        onResponderRelease={(event) => {
          if (!dragStart) return;

          const end = {
            x: event.nativeEvent.locationX,
            y: event.nativeEvent.locationY,
          };
          const next = rectFromPoints(dragStart, end, size, level);

          if (next.width >= 0.005 && next.height >= 0.005) {
            setDraftRect(next);
          }

          setDragStart(null);
          setDragEnd(null);
        }}
        onResponderTerminate={() => {
          setDragStart(null);
          setDragEnd(null);
        }}
      />

      <View style={styles.header} pointerEvents="box-none">
        <Pressable accessibilityRole="button" style={styles.backButton} onPress={onExit}>
          <Text style={styles.backText}>‹ Exit authoring</Text>
        </Pressable>

        <View style={styles.titleCard} pointerEvents="none">
          <Text style={styles.eyebrow}>DEV TOOL</Text>
          <Text style={styles.title}>{level.title} hitboxes</Text>
          <Text style={styles.subtitle}>Drag a box around an object.</Text>
        </View>
      </View>

      <View style={styles.outputCard} pointerEvents="box-none">
        <Text style={styles.outputTitle}>New target rectangle</Text>
        {draftRect ? (
          <>
            <Text selectable style={styles.code}>{rectCode(draftRect)}</Text>
            <Text style={styles.help}>Long-press the line to copy it into `src/data/levels.ts`.</Text>
            <Pressable style={styles.clearButton} onPress={() => setDraftRect(null)}>
              <Text style={styles.clearButtonText}>Clear draft</Text>
            </Pressable>
          </>
        ) : (
          <Text style={styles.emptyText}>No draft yet. Drag directly on the scene.</Text>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#111827', overflow: 'hidden' },
  scene: { ...StyleSheet.absoluteFill, width: '100%', height: '100%' },
  existingRect: {
    position: 'absolute',
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.8)',
    backgroundColor: 'rgba(255,255,255,0.08)',
  },
  existingLabel: {
    position: 'absolute',
    left: 2,
    top: 2,
    paddingHorizontal: 5,
    paddingVertical: 2,
    borderRadius: 5,
    overflow: 'hidden',
    backgroundColor: 'rgba(17,24,39,0.82)',
    color: 'white',
    fontSize: 10,
    fontWeight: '900',
  },
  draftRect: {
    position: 'absolute',
    borderWidth: 4,
    borderColor: '#facc15',
    backgroundColor: 'rgba(250,204,21,0.18)',
  },
  header: {
    position: 'absolute',
    top: 16,
    left: 18,
    right: 18,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  backButton: {
    paddingHorizontal: 18,
    paddingVertical: 11,
    borderRadius: 999,
    backgroundColor: 'rgba(17,24,39,0.9)',
  },
  backText: { color: 'white', fontSize: 15, fontWeight: '900' },
  titleCard: {
    paddingHorizontal: 18,
    paddingVertical: 11,
    borderRadius: 16,
    backgroundColor: 'rgba(17,24,39,0.9)',
    alignItems: 'flex-end',
  },
  eyebrow: { color: '#facc15', fontSize: 10, fontWeight: '900', letterSpacing: 1.4 },
  title: { color: 'white', fontSize: 17, fontWeight: '900', marginTop: 2 },
  subtitle: { color: '#d1d5db', fontSize: 12, marginTop: 2 },
  outputCard: {
    position: 'absolute',
    left: 18,
    bottom: 18,
    width: 470,
    padding: 15,
    borderRadius: 16,
    backgroundColor: 'rgba(17,24,39,0.94)',
  },
  outputTitle: { color: 'white', fontSize: 14, fontWeight: '900' },
  code: {
    marginTop: 9,
    padding: 10,
    borderRadius: 9,
    overflow: 'hidden',
    backgroundColor: 'rgba(255,255,255,0.1)',
    color: '#fef3c7',
    fontFamily: 'Courier',
    fontSize: 13,
  },
  help: { color: '#d1d5db', fontSize: 11, marginTop: 7 },
  emptyText: { color: '#d1d5db', fontSize: 13, marginTop: 7 },
  clearButton: {
    alignSelf: 'flex-start',
    marginTop: 9,
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 9,
    backgroundColor: 'rgba(255,255,255,0.12)',
  },
  clearButtonText: { color: 'white', fontWeight: '800', fontSize: 12 },
});
