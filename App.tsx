import React, { useEffect, useMemo, useState } from 'react';
import {
  Image,
  ImageBackground,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SceneGame } from './src/components/SceneGame';
import { animalsLevel } from './src/data/levels';

type Screen = 'splash' | 'dashboard' | 'bookshelf' | 'book' | 'game';
type ParentDestination = 'settings' | 'purchase' | null;

const art = {
  splash: require('./assets/splash.png'),
  dashboard: require('./assets/dashboard.png'),
  bookshelf: require('./assets/bookshelf.png'),
  bookshelfCard: require('./assets/bookshelf-card.png'),
  animalsCard: require('./assets/animals-card.png'),
  animalsWallpaper: require('./assets/animals-wallpaper.png'),
};

function randomPrompt() {
  const plus = Math.random() > 0.5;
  if (plus) {
    const a = Math.floor(Math.random() * 10);
    const b = Math.floor(Math.random() * (10 - a));
    return { question: `${a} + ${b} = ?`, answer: a + b };
  }
  const a = Math.floor(Math.random() * 10);
  const b = Math.floor(Math.random() * (a + 1));
  return { question: `${a} - ${b} = ?`, answer: a - b };
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('splash');
  const [parentDestination, setParentDestination] = useState<ParentDestination>(null);
  const [parentUnlocked, setParentUnlocked] = useState<ParentDestination>(null);

  useEffect(() => {
    if (screen !== 'splash') return;
    const timer = setTimeout(() => setScreen('dashboard'), 2200);
    return () => clearTimeout(timer);
  }, [screen]);

  return (
    <View style={styles.app}>
      <StatusBar hidden />
      {screen === 'splash' ? <Splash /> : null}
      {screen === 'dashboard' ? (
        <Dashboard
          onOpenBookshelf={() => setScreen('bookshelf')}
          onParentAction={setParentDestination}
        />
      ) : null}
      {screen === 'bookshelf' ? (
        <Bookshelf onBack={() => setScreen('dashboard')} onOpenAnimals={() => setScreen('book')} />
      ) : null}
      {screen === 'book' ? (
        <Book onBack={() => setScreen('bookshelf')} onOpenLevel={() => setScreen('game')} />
      ) : null}
      {screen === 'game' ? <SceneGame level={animalsLevel} onExit={() => setScreen('book')} /> : null}

      <ParentGate
        destination={parentDestination}
        onCancel={() => setParentDestination(null)}
        onSuccess={(destination) => {
          setParentDestination(null);
          setParentUnlocked(destination);
        }}
      />
      <ParentPanel destination={parentUnlocked} onClose={() => setParentUnlocked(null)} />
    </View>
  );
}

function Splash() {
  return <Image source={art.splash} style={styles.fullImage} resizeMode="cover" />;
}

function Dashboard({
  onOpenBookshelf,
  onParentAction,
}: {
  onOpenBookshelf: () => void;
  onParentAction: (destination: ParentDestination) => void;
}) {
  return (
    <ImageBackground source={art.dashboard} style={styles.screen} resizeMode="cover">
      <View style={styles.parentButtons}>
        <RoundButton label="👑" accessibilityLabel="Purchases" onPress={() => onParentAction('purchase')} />
        <RoundButton label="⚙️" accessibilityLabel="Settings" onPress={() => onParentAction('settings')} />
      </View>
      <Pressable style={styles.dashboardCard} onPress={onOpenBookshelf}>
        <Image source={art.bookshelfCard} style={styles.dashboardCardImage} resizeMode="cover" />
        <View style={styles.cardShade} />
        <Text style={styles.dashboardCardTitle}>Bookshelf</Text>
      </Pressable>
    </ImageBackground>
  );
}

function Bookshelf({ onBack, onOpenAnimals }: { onBack: () => void; onOpenAnimals: () => void }) {
  return (
    <ImageBackground source={art.bookshelf} style={styles.screen} resizeMode="cover">
      <TopBack title="Bookshelf" onBack={onBack} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.bookRow}>
        <BookCard title="Animals" image={art.animalsCard} onPress={onOpenAnimals} />
        <BookCard title="Coming Soon" image={art.bookshelfCard} locked />
        <BookCard title="Coming Soon" image={art.bookshelfCard} locked />
      </ScrollView>
    </ImageBackground>
  );
}

function Book({ onBack, onOpenLevel }: { onBack: () => void; onOpenLevel: () => void }) {
  return (
    <ImageBackground source={art.animalsWallpaper} style={styles.screen} resizeMode="cover">
      <View style={styles.lightWash} />
      <TopBack title="Animals" onBack={onBack} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.pageRow}>
        {Array.from({ length: 10 }).map((_, index) => (
          <PageCard
            key={index}
            index={index}
            available={index === 0}
            onPress={index === 0 ? onOpenLevel : undefined}
          />
        ))}
      </ScrollView>
    </ImageBackground>
  );
}

function RoundButton({ label, accessibilityLabel, onPress }: { label: string; accessibilityLabel: string; onPress: () => void }) {
  return (
    <Pressable accessibilityLabel={accessibilityLabel} onPress={onPress} style={styles.roundButton}>
      <Text style={styles.roundButtonText}>{label}</Text>
    </Pressable>
  );
}

function TopBack({ title, onBack }: { title: string; onBack: () => void }) {
  return (
    <View style={styles.topBar}>
      <Pressable style={styles.backCircle} onPress={onBack}>
        <Text style={styles.backCircleText}>‹</Text>
      </Pressable>
      <Text style={styles.topTitle}>{title}</Text>
    </View>
  );
}

function BookCard({ title, image, locked, onPress }: { title: string; image: any; locked?: boolean; onPress?: () => void }) {
  return (
    <Pressable disabled={locked} onPress={onPress} style={styles.bookCardWrap}>
      <View style={styles.bookCard}>
        <Image source={image} style={styles.bookCardImage} resizeMode="cover" />
        {locked ? <View style={styles.lockShade} /> : null}
        <Text style={[styles.bookTitle, locked && styles.lockedTitle]}>{title}</Text>
      </View>
      <Text style={styles.bookBadge}>{locked ? '🔒 Locked' : '▶ Play'}</Text>
    </Pressable>
  );
}

function PageCard({ index, available, onPress }: { index: number; available: boolean; onPress?: () => void }) {
  return (
    <Pressable disabled={!available} onPress={onPress} style={[styles.pageCard, available ? styles.pageAvailable : styles.pageLocked]}>
      <Image source={art.animalsCard} style={styles.pageImage} resizeMode="cover" />
      {!available ? <View style={styles.pageLockShade} /> : null}
      <Text style={styles.pageTitle}>Page {index + 1}</Text>
      <Text style={styles.pageStatus}>{available ? '🙂' : '⭐'}</Text>
    </Pressable>
  );
}

function ParentGate({
  destination,
  onCancel,
  onSuccess,
}: {
  destination: ParentDestination;
  onCancel: () => void;
  onSuccess: (destination: Exclude<ParentDestination, null>) => void;
}) {
  const prompt = useMemo(() => randomPrompt(), [destination]);
  const [error, setError] = useState(false);

  useEffect(() => setError(false), [destination]);

  if (!destination) return null;

  return (
    <Modal transparent visible animationType="fade" supportedOrientations={['landscape']}>
      <View style={styles.modalScrim}>
        <View style={styles.parentCard}>
          <Text style={styles.parentTitle}>Parents Only</Text>
          <Text style={styles.parentCopy}>Tap the correct answer to continue.</Text>
          <Text style={styles.mathQuestion}>{prompt.question}</Text>
          <View style={styles.numberGrid}>
            {Array.from({ length: 10 }).map((_, number) => (
              <Pressable
                key={number}
                style={styles.numberButton}
                onPress={() => {
                  if (number === prompt.answer) {
                    setError(false);
                    onSuccess(destination);
                  } else {
                    setError(true);
                  }
                }}
              >
                <Text style={styles.numberButtonText}>{number}</Text>
              </Pressable>
            ))}
          </View>
          {error ? <Text style={styles.errorText}>Not quite. Try again.</Text> : null}
          <Pressable onPress={onCancel}><Text style={styles.cancelText}>Cancel</Text></Pressable>
        </View>
      </View>
    </Modal>
  );
}

function ParentPanel({ destination, onClose }: { destination: ParentDestination; onClose: () => void }) {
  const [music, setMusic] = useState(true);
  const [sfx, setSfx] = useState(true);
  const [timer, setTimer] = useState(false);

  if (!destination) return null;

  return (
    <Modal transparent visible animationType="fade" supportedOrientations={['landscape']}>
      <View style={styles.modalScrim}>
        <View style={styles.parentCard}>
          <Text style={styles.parentTitle}>{destination === 'settings' ? 'Settings' : 'Unlock iFind'}</Text>
          {destination === 'settings' ? (
            <View style={styles.settingsList}>
              <SettingRow label="Music" value={music} onValueChange={setMusic} />
              <SettingRow label="Sound effects" value={sfx} onValueChange={setSfx} />
              <SettingRow label="15 minute timer" value={timer} onValueChange={setTimer} />
              <Text style={styles.phaseNote}>Phase 0: settings are visual only for now.</Text>
            </View>
          ) : (
            <>
              <Text style={styles.purchaseHeadline}>Unlock all interactive books</Text>
              <Text style={styles.parentCopy}>The original $2.99 one-time unlock concept is preserved. StoreKit comes after the playable baseline.</Text>
              <View style={styles.disabledPurchase}><Text style={styles.disabledPurchaseText}>$2.99 · Coming in a later phase</Text></View>
            </>
          )}
          <Pressable style={styles.primaryClose} onPress={onClose}><Text style={styles.primaryCloseText}>Done</Text></Pressable>
        </View>
      </View>
    </Modal>
  );
}

function SettingRow({ label, value, onValueChange }: { label: string; value: boolean; onValueChange: (value: boolean) => void }) {
  return (
    <View style={styles.settingRow}>
      <Text style={styles.settingLabel}>{label}</Text>
      <Switch value={value} onValueChange={onValueChange} />
    </View>
  );
}

const styles = StyleSheet.create({
  app: { flex: 1, backgroundColor: '#101a35' },
  screen: { flex: 1 },
  fullImage: { width: '100%', height: '100%' },
  parentButtons: { position: 'absolute', top: 18, right: 24, zIndex: 5, flexDirection: 'row', gap: 10 },
  roundButton: { width: 54, height: 54, borderRadius: 27, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(255,255,255,0.88)' },
  roundButtonText: { fontSize: 24 },
  dashboardCard: { position: 'absolute', alignSelf: 'center', top: '25%', width: 330, height: 245, borderRadius: 24, overflow: 'hidden', borderWidth: 12, borderColor: 'rgba(255,255,255,0.85)' },
  dashboardCardImage: { width: '100%', height: '100%' },
  cardShade: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.10)' },
  dashboardCardTitle: { position: 'absolute', alignSelf: 'center', top: '40%', color: 'white', fontSize: 38, fontWeight: '900', textShadowColor: 'rgba(0,0,0,0.4)', textShadowRadius: 5 },
  topBar: { position: 'absolute', top: 18, left: 28, right: 28, zIndex: 5, flexDirection: 'row', alignItems: 'center', gap: 16 },
  backCircle: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#1a2c71', alignItems: 'center', justifyContent: 'center' },
  backCircleText: { color: 'white', fontSize: 38, lineHeight: 40, fontWeight: '800', marginTop: -3 },
  topTitle: { fontSize: 36, fontWeight: '900', color: '#172036' },
  bookRow: { paddingTop: 115, paddingHorizontal: 84, paddingBottom: 30, gap: 34, alignItems: 'center' },
  bookCardWrap: { alignItems: 'center', width: 270 },
  bookCard: { width: 260, height: 205, borderRadius: 18, overflow: 'hidden', borderWidth: 10, borderColor: '#111827', backgroundColor: 'white' },
  bookCardImage: { width: '100%', height: '100%' },
  lockShade: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.44)' },
  bookTitle: { position: 'absolute', alignSelf: 'center', top: '40%', fontSize: 28, fontWeight: '900', color: '#111827', textShadowColor: 'white', textShadowRadius: 4 },
  lockedTitle: { color: 'white', textShadowColor: 'rgba(0,0,0,0.4)' },
  bookBadge: { marginTop: 12, paddingHorizontal: 14, paddingVertical: 7, overflow: 'hidden', borderRadius: 999, backgroundColor: 'rgba(17,24,39,0.78)', color: 'white', fontWeight: '800' },
  lightWash: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(255,255,255,0.46)' },
  pageRow: { paddingTop: 112, paddingHorizontal: 70, paddingBottom: 30, gap: 26, alignItems: 'center' },
  pageCard: { width: 164, height: 218, borderRadius: 18, overflow: 'hidden', borderWidth: 9, backgroundColor: '#fff', alignItems: 'center' },
  pageAvailable: { borderColor: '#3d8ef7' },
  pageLocked: { borderColor: '#f1cf3f' },
  pageImage: { width: '100%', height: '100%' },
  pageLockShade: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.38)' },
  pageTitle: { position: 'absolute', top: 76, fontSize: 18, fontWeight: '900', color: '#111827', backgroundColor: 'rgba(255,255,255,0.74)', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  pageStatus: { position: 'absolute', bottom: 10, fontSize: 26 },
  modalScrim: { flex: 1, backgroundColor: 'rgba(10,16,30,0.52)', alignItems: 'center', justifyContent: 'center' },
  parentCard: { width: 500, maxHeight: '88%', padding: 26, borderRadius: 26, backgroundColor: 'white', alignItems: 'center' },
  parentTitle: { fontSize: 30, fontWeight: '900', color: '#172036' },
  parentCopy: { marginTop: 7, fontSize: 16, color: '#667085', textAlign: 'center', lineHeight: 22 },
  mathQuestion: { marginTop: 16, fontSize: 34, fontWeight: '900', color: '#172036' },
  numberGrid: { marginTop: 14, flexDirection: 'row', flexWrap: 'wrap', width: 360, justifyContent: 'center', gap: 10 },
  numberButton: { width: 58, height: 52, borderRadius: 26, backgroundColor: '#3478f6', alignItems: 'center', justifyContent: 'center' },
  numberButtonText: { color: 'white', fontWeight: '900', fontSize: 20 },
  errorText: { marginTop: 10, color: '#d92d20', fontWeight: '800' },
  cancelText: { marginTop: 14, color: '#667085', fontWeight: '800', fontSize: 16 },
  settingsList: { width: '100%', marginTop: 16, gap: 10 },
  settingRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, paddingHorizontal: 6 },
  settingLabel: { fontSize: 18, fontWeight: '700', color: '#172036' },
  phaseNote: { marginTop: 8, color: '#667085', textAlign: 'center' },
  purchaseHeadline: { marginTop: 18, fontSize: 22, fontWeight: '900', color: '#172036', textTransform: 'uppercase', textAlign: 'center' },
  disabledPurchase: { marginTop: 18, paddingHorizontal: 22, paddingVertical: 13, borderRadius: 999, backgroundColor: '#f2f4f7' },
  disabledPurchaseText: { color: '#667085', fontWeight: '800' },
  primaryClose: { marginTop: 20, paddingHorizontal: 28, paddingVertical: 12, borderRadius: 999, backgroundColor: '#f59e0b' },
  primaryCloseText: { color: 'white', fontWeight: '900', fontSize: 17 },
});
