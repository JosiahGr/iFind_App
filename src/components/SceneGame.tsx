import React, { useMemo, useState } from 'react';
import {
  Image,
  LayoutChangeEvent,
  Pressable,
  StyleSheet,
  Text,
  Vibration,
  View,
} from 'react-native';
import type { Level } from '../data/levels';

type Props = {
  level: Level;
  onExit: () => void;
};

type Size = { width: number; height: number };
type Point = { x: number; y: number };

function mapTouchToImage(point: Point, container: Size, level: Level): Point {
  const scale = Math.max(
    container.width / level.sceneWidth,
    container.height / level.sceneHeight,
  );
  const renderedWidth = level.sceneWidth * scale;
  const renderedHeight = level.sceneHeight * scale;
  const offsetX = (container.width - renderedWidth) / 2;
  const offsetY = (container.height - renderedHeight) / 2;

  return {
    x: (point.x - offsetX) / scale,
    y: (point.y - offsetY) / scale,
  };
}

export function SceneGame({ level, onExit }: Props) {
  const [size, setSize] = useState<Size>({ width: 1, height: 1 });
  const [currentIndex, setCurrentIndex] = useState(0);
  const [found, setFound] = useState(0);
  const [marker, setMarker] = useState<Point | null>(null);
  const [won, setWon] = useState(false);

  const target = level.targets[Math.min(currentIndex, level.targets.length - 1)];
  const stars = useMemo(
    () => level.targets.map((_, index) => (index < found ? '★' : '☆')).join(' '),
    [found, level.targets],
  );

  function reset() {
    setCurrentIndex(0);
    setFound(0);
    setMarker(null);
    setWon(false);
  }

  function handleLayout(event: LayoutChangeEvent) {
    const { width, height } = event.nativeEvent.layout;
    setSize({ width, height });
  }

  function handlePress(x: number, y: number) {
    if (won || !target) return;

    const imagePoint = mapTouchToImage({ x, y }, size, level);
    const rect = {
      x: target.rect.x * level.sceneWidth,
      y: target.rect.y * level.sceneHeight,
      width: target.rect.width * level.sceneWidth,
      height: target.rect.height * level.sceneHeight,
    };

    const hit =
      imagePoint.x >= rect.x &&
      imagePoint.x <= rect.x + rect.width &&
      imagePoint.y >= rect.y &&
      imagePoint.y <= rect.y + rect.height;

    if (!hit) {
      Vibration.vibrate(35);
      return;
    }

    Vibration.vibrate(15);
    setMarker({ x, y });
    setTimeout(() => setMarker(null), 650);

    const nextFound = found + 1;
    setFound(nextFound);

    if (nextFound >= level.targets.length) {
      setWon(true);
    } else {
      setCurrentIndex(currentIndex + 1);
    }
  }

  return (
    <View style={styles.root} onLayout={handleLayout}>
      <Pressable
        style={StyleSheet.absoluteFill}
        onPress={(event) =>
          handlePress(event.nativeEvent.locationX, event.nativeEvent.locationY)
        }
      >
        <Image source={level.scene} style={styles.scene} resizeMode="cover" />
      </Pressable>

      <Pressable style={styles.backButton} onPress={onExit}>
        <Text style={styles.backText}>‹ Back</Text>
      </Pressable>

      <View style={styles.starMeter} pointerEvents="none">
        <Text style={styles.starText}>{stars}</Text>
      </View>

      {!won && target ? (
        <View style={styles.targetCard} pointerEvents="none">
          <Text style={styles.findLabel}>Find</Text>
          <Image source={target.thumbnail} style={styles.targetImage} resizeMode="contain" />
          <Text style={styles.targetLabel}>{target.label}</Text>
        </View>
      ) : null}

      {marker ? (
        <View style={[styles.marker, { left: marker.x - 24, top: marker.y - 24 }]} pointerEvents="none">
          <Text style={styles.markerText}>✓</Text>
        </View>
      ) : null}

      {won ? (
        <View style={styles.winScrim}>
          <View style={styles.winCard}>
            <Text style={styles.sparkles}>✨</Text>
            <Text style={styles.winTitle}>Great job!</Text>
            <Text style={styles.winBody}>You found them all!</Text>
            <View style={styles.winActions}>
              <Pressable style={styles.secondaryButton} onPress={reset}>
                <Text style={styles.secondaryButtonText}>Restart</Text>
              </Pressable>
              <Pressable style={styles.primaryButton} onPress={onExit}>
                <Text style={styles.primaryButtonText}>Continue</Text>
              </Pressable>
            </View>
          </View>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#132345' },
  scene: { width: '100%', height: '100%' },
  backButton: {
    position: 'absolute',
    top: 18,
    left: 22,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 999,
    backgroundColor: 'rgba(20,34,79,0.92)',
  },
  backText: { color: 'white', fontWeight: '800', fontSize: 18 },
  starMeter: {
    position: 'absolute',
    top: 18,
    right: 22,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.9)',
  },
  starText: { color: '#f59e0b', fontWeight: '900', fontSize: 18 },
  targetCard: {
    position: 'absolute',
    right: 22,
    bottom: 20,
    width: 126,
    alignItems: 'center',
    padding: 10,
    borderRadius: 18,
    backgroundColor: 'rgba(255,255,255,0.96)',
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
  },
  findLabel: { fontSize: 12, fontWeight: '800', color: '#667085', textTransform: 'uppercase' },
  targetImage: { width: 86, height: 72, marginVertical: 2 },
  targetLabel: { fontSize: 16, fontWeight: '900', color: '#172036' },
  marker: {
    position: 'absolute',
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(255,255,255,0.92)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  markerText: { fontSize: 30, color: '#22a06b', fontWeight: '900' },
  winScrim: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(13,22,43,0.45)',
  },
  winCard: {
    width: 390,
    padding: 28,
    borderRadius: 24,
    backgroundColor: 'rgba(255,255,255,0.97)',
    alignItems: 'center',
  },
  sparkles: { fontSize: 44 },
  winTitle: { fontSize: 38, fontWeight: '900', color: '#172036', marginTop: 4 },
  winBody: { fontSize: 18, color: '#667085', marginTop: 4 },
  winActions: { flexDirection: 'row', gap: 14, marginTop: 22 },
  primaryButton: { paddingHorizontal: 24, paddingVertical: 13, borderRadius: 999, backgroundColor: '#f59e0b' },
  primaryButtonText: { color: 'white', fontWeight: '900', fontSize: 17 },
  secondaryButton: { paddingHorizontal: 24, paddingVertical: 13, borderRadius: 999, backgroundColor: '#e9edf5' },
  secondaryButtonText: { color: '#172036', fontWeight: '900', fontSize: 17 },
});
