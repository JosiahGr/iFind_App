import React, { useEffect, useState } from 'react';
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
  type ImageSourcePropType,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SceneGame } from './src/components/SceneGame';
import { animalsBook, type BookDefinition, type PageDefinition } from './src/data/catalog';
import type { Level } from './src/data/levels';
import { AppStateProvider, useAppState } from './src/state/AppStateContext';

type Screen = 'splash' | 'dashboard' | 'bookshelf' | 'book' | 'game';
type ParentDestination = 'settings' | 'purchase' | null;
type PageStatus = 'available' | 'completed' | 'locked' | 'upcoming';

const art = {
  splash: require('./assets/splash.png'),
  dashboard: require('./assets/dashboard.png'),
  bookshelf: require('./assets/bookshelf.png'),
  bookshelfCard: require('./assets/bookshelf-card.png'),
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
  return (
    <AppStateProvider>
      <IFindApp />
    </AppStateProvider>
  );
}

function IFindApp() {
  const { hydrated, completedLevelIds, settings, completeLevel, resetProgress, setSetting } = useAppState();
  const [screen, setScreen] = useState<Screen>('splash');
  const [splashElapsed, setSplashElapsed] = useState(false);
  const [activeLevel, setActiveLevel] = useState<Level | null>(null);
  const [parentDestination, setParentDestination] = useState<ParentDestination>(null);
  const [parentUnlocked, setParentUnlocked] = useState<ParentDestination>(null);

  useEffect(() => {
    const timer = setTimeout(() => setSplashElapsed(true), 1800);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (screen === 'splash' && splashElapsed && hydrated) {
      setScreen('dashboard');
    }
  }, [hydrated, screen, splashElapsed]);

  function openLevel(level: Level) {
    setActiveLevel(level);
    setScreen('game');
  }

  function leaveGame() {
    setActiveLevel(null);
    setScreen('book');
  }

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
        <Bookshelf
          completedLevelIds={completedLevelIds}
          onBack={() => setScreen('dashboard')}
          onOpenAnimals={() => setScreen('book')}
        />
      ) : null}

      {screen === 'book' ? (
        <BookScreen
          book={animalsBook}
          completedLevelIds={completedLevelIds}
          onBack={() => setScreen('bookshelf')}
          onOpenLevel={openLevel}
        />
      ) : null}

      {screen === 'game' && activeLevel ? (
        <SceneGame level={activeLevel} onExit={leaveGame} onComplete={completeLevel} />
      ) : null}

      <ParentGate
        destination={parentDestination}
        onCancel={() => setParentDestination(null)}
        onSuccess={(destination) => {
          setParentDestination(null);
          setParentUnlocked(destination);
        }}
      />

      <ParentPanel
        destination={parentUnlocked}
        settings={settings}
        onSettingChange={setSetting}
        onResetProgress={resetProgress}
        onClose={() => setParentUnlocked(null)}
      />
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
  onParentAction: (destination: Exclude<ParentDestination, null>) => void;
}) {
  return (
    <ImageBackground source={art.dashboard} style={styles.screen} resizeMode="cover">
      <View style={styles.parentButtons}>
        <RoundButton label="👑" accessibilityLabel="Purchases" onPress={() => onParentAction('purchase')} />
        <RoundButton label="⚙️" accessibilityLabel="Settings" onPress={() => onParentAction('settings')} />
      </View>

      <Pressable accessibilityRole="button" style={styles.dashboardCard} onPress={onOpenBookshelf}>
        <Image source={art.bookshelfCard} style={styles.dashboardCardImage} resizeMode="cover" />
        <View style={styles.cardShade} />
        <Text style={styles.dashboardCardTitle}>Bookshelf</Text>
        <Text style={styles.dashboardCardCopy}>Choose a book and start finding.</Text>
      </Pressable>
    </ImageBackground>
  );
}

function Bookshelf({
  completedLevelIds,
  onBack,
  onOpenAnimals,
}: {
  completedLevelIds: string[];
  onBack: () => void;
  onOpenAnimals: () => void;
}) {
  const playable = animalsBook.pages.filter((page) => page.level);
  const complete = playable.filter((page) => page.level && completedLevelIds.includes(page.level.id)).length;

  return (
    <ImageBackground source={art.bookshelf} style={styles.screen} resizeMode="cover">
      <TopBack title="Bookshelf" onBack={onBack} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.bookRow}>
        <BookCard
          title="Animals"
          subtitle={playable.length > 0 ? `${complete}/${playable.length} complete` : 'Coming soon'}
          image={animalsBook.cover}
          onPress={onOpenAnimals}
        />
        <BookCard title="Coming Soon" subtitle="New adventure" image={art.bookshelfCard} locked />
        <BookCard title="Coming Soon" subtitle="New adventure" image={art.bookshelfCard} locked />
      </ScrollView>
    </ImageBackground>
  );
}

function pageStatus(book: BookDefinition, page: PageDefinition, index: number, completedLevelIds: string[]): PageStatus {
  if (!page.level) return 'upcoming';
  if (completedLevelIds.includes(page.level.id)) return 'completed';
  if (index === 0) return 'available';

  const previous = book.pages[index - 1];
  if (previous?.level && completedLevelIds.includes(previous.level.id)) {
    return 'available';
  }

  return 'locked';
}

function BookScreen({
  book,
  completedLevelIds,
  onBack,
  onOpenLevel,
}: {
  book: BookDefinition;
  completedLevelIds: string[];
  onBack: () => void;
  onOpenLevel: (level: Level) => void;
}) {
  return (
    <ImageBackground source={book.wallpaper} style={styles.screen} resizeMode="cover">
      <View style={styles.lightWash} />
      <TopBack title={book.title} onBack={onBack} />

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.pageRow}>
        {book.pages.map((page, index) => {
          const status = pageStatus(book, page, index, completedLevelIds);
          return (
            <PageCard
              key={page.id}
              page={page}
              status={status}
              onPress={page.level && (status === 'available' || status === 'completed') ? () => onOpenLevel(page.level!) : undefined}
            />
          );
        })}
      </ScrollView>
    </ImageBackground>
  );
}

function RoundButton({
  label,
  accessibilityLabel,
  onPress,
}: {
  label: string;
  accessibilityLabel: string;
  onPress: () => void;
}) {
  return (
    <Pressable accessibilityRole="button" accessibilityLabel={accessibilityLabel} onPress={onPress} style={styles.roundButton}>
      <Text style={styles.roundButtonText}>{label}</Text>
    </Pressable>
  );
}

function TopBack({ title, onBack }: { title: string; onBack: () => void }) {
  return (
    <View style={styles.topBar}>
      <Pressable accessibilityRole="button" accessibilityLabel="Back" style={styles.backCircle} onPress={onBack}>
        <Text style={styles.backCircleText}>‹</Text>
      </Pressable>
      <Text style={styles.topTitle}>{title}</Text>
    </View>
  );
}

function BookCard({
  title,
  subtitle,
  image,
  locked,
  onPress,
}: {
  title: string;
  subtitle: string;
  image: ImageSourcePropType;
  locked?: boolean;
  onPress?: () => void;
}) {
  return (
    <Pressable disabled={locked} onPress={onPress} style={styles.bookCardWrap}>
      <View style={styles.bookCard}>
        <Image source={image} style={styles.bookCardImage} resizeMode="cover" />
        {locked ? <View style={styles.lockShade} /> : null}
        <Text style={[styles.bookTitle, locked && styles.lockedTitle]}>{title}</Text>
      </View>
      <Text style={styles.bookBadge}>{locked ? '🔒 Locked' : `▶ ${subtitle}`}</Text>
    </Pressable>
  );
}

function PageCard({
  page,
  status,
  onPress,
}: {
  page: PageDefinition;
  status: PageStatus;
  onPress?: () => void;
}) {
  const playable = status === 'available' || status === 'completed';
  const statusLabel = status === 'completed' ? '✓' : status === 'available' ? '🙂' : status === 'locked' ? '🔒' : 'Soon';

  return (
    <Pressable
      accessibilityRole="button"
      disabled={!playable}
      onPress={onPress}
      style={[
        styles.pageCard,
        status === 'completed' && styles.pageCompleted,
        status === 'available' && styles.pageAvailable,
        (status === 'locked' || status === 'upcoming') && styles.pageLocked,
      ]}
    >
      <Image source={page.thumbnail} style={styles.pageImage} resizeMode="cover" />
      {!playable ? <View style={styles.pageLockShade} /> : null}
      <Text style={styles.pageTitle}>{page.title}</Text>
      <View style={[styles.pageStatusBadge, status === 'completed' && styles.pageStatusComplete]}>
        <Text style={styles.pageStatusText}>{statusLabel}</Text>
      </View>
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
  const [prompt, setPrompt] = useState(randomPrompt);
  const [error, setError] = useState(false);

  useEffect(() => {
    if (!destination) return;
    setPrompt(randomPrompt());
    setError(false);
  }, [destination]);

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
                    setPrompt(randomPrompt());
                  }
                }}
              >
                <Text style={styles.numberButtonText}>{number}</Text>
              </Pressable>
            ))}
          </View>

          {error ? <Text style={styles.errorText}>Not quite. Here is another one.</Text> : null}
          <Pressable onPress={onCancel}>
            <Text style={styles.cancelText}>Cancel</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

function ParentPanel({
  destination,
  settings,
  onSettingChange,
  onResetProgress,
  onClose,
}: {
  destination: ParentDestination;
  settings: { music: boolean; sfx: boolean; timer: boolean };
  onSettingChange: (key: 'music' | 'sfx' | 'timer', value: boolean) => void;
  onResetProgress: () => void;
  onClose: () => void;
}) {
  const [resetDone, setResetDone] = useState(false);

  useEffect(() => setResetDone(false), [destination]);

  if (!destination) return null;

  return (
    <Modal transparent visible animationType="fade" supportedOrientations={['landscape']}>
      <View style={styles.modalScrim}>
        <View style={styles.parentCard}>
          <Text style={styles.parentTitle}>{destination === 'settings' ? 'Settings' : 'Unlock iFind'}</Text>

          {destination === 'settings' ? (
            <View style={styles.settingsList}>
              <SettingRow label="Music" value={settings.music} onValueChange={(value) => onSettingChange('music', value)} />
              <SettingRow label="Sound effects" value={settings.sfx} onValueChange={(value) => onSettingChange('sfx', value)} />
              <SettingRow label="15 minute timer" value={settings.timer} onValueChange={(value) => onSettingChange('timer', value)} />

              <Pressable
                style={styles.resetButton}
                onPress={() => {
                  onResetProgress();
                  setResetDone(true);
                }}
              >
                <Text style={styles.resetButtonText}>{resetDone ? 'Progress reset ✓' : 'Reset progress'}</Text>
              </Pressable>

              <Text style={styles.phaseNote}>Progress and preferences now save on this device.</Text>
            </View>
          ) : (
            <>
              <Text style={styles.purchaseHeadline}>Unlock all interactive books</Text>
              <Text style={styles.parentCopy}>
                The original $2.99 one-time unlock concept is preserved. StoreKit comes after the revived core experience is stable.
              </Text>
              <View style={styles.disabledPurchase}>
                <Text style={styles.disabledPurchaseText}>$2.99 · Coming in a later phase</Text>
              </View>
            </>
          )}

          <Pressable style={styles.primaryClose} onPress={onClose}>
            <Text style={styles.primaryCloseText}>Done</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

function SettingRow({
  label,
  value,
  onValueChange,
}: {
  label: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}) {
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
  roundButton: { width: 54, height: 54, borderRadius: 27, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(255,255,255,0.9)' },
  roundButtonText: { fontSize: 24 },
  dashboardCard: { position: 'absolute', alignSelf: 'center', top: '23%', width: 350, height: 255, borderRadius: 24, overflow: 'hidden', borderWidth: 12, borderColor: 'rgba(255,255,255,0.88)' },
  dashboardCardImage: { width: '100%', height: '100%' },
  cardShade: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.12)' },
  dashboardCardTitle: { position: 'absolute', alignSelf: 'center', top: '34%', color: 'white', fontSize: 40, fontWeight: '900', textShadowColor: 'rgba(0,0,0,0.45)', textShadowRadius: 5 },
  dashboardCardCopy: { position: 'absolute', alignSelf: 'center', top: '58%', color: 'white', fontSize: 15, fontWeight: '800', textShadowColor: 'rgba(0,0,0,0.45)', textShadowRadius: 4 },
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
  bookBadge: { marginTop: 12, paddingHorizontal: 14, paddingVertical: 7, overflow: 'hidden', borderRadius: 999, backgroundColor: 'rgba(17,24,39,0.8)', color: 'white', fontWeight: '800' },
  lightWash: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(255,255,255,0.46)' },
  pageRow: { paddingTop: 112, paddingHorizontal: 70, paddingBottom: 30, gap: 26, alignItems: 'center' },
  pageCard: { width: 164, height: 218, borderRadius: 18, overflow: 'hidden', borderWidth: 9, backgroundColor: '#fff', alignItems: 'center' },
  pageAvailable: { borderColor: '#3d8ef7' },
  pageCompleted: { borderColor: '#22a06b' },
  pageLocked: { borderColor: '#f1cf3f' },
  pageImage: { width: '100%', height: '100%' },
  pageLockShade: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.38)' },
  pageTitle: { position: 'absolute', top: 76, fontSize: 18, fontWeight: '900', color: '#111827', backgroundColor: 'rgba(255,255,255,0.78)', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  pageStatusBadge: { position: 'absolute', bottom: 10, minWidth: 42, minHeight: 34, paddingHorizontal: 8, borderRadius: 17, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(255,255,255,0.9)' },
  pageStatusComplete: { backgroundColor: 'rgba(224,250,239,0.96)' },
  pageStatusText: { fontSize: 18, fontWeight: '900', color: '#172036' },
  modalScrim: { flex: 1, backgroundColor: 'rgba(10,16,30,0.55)', alignItems: 'center', justifyContent: 'center' },
  parentCard: { width: 500, maxHeight: '90%', padding: 26, borderRadius: 26, backgroundColor: 'white', alignItems: 'center' },
  parentTitle: { fontSize: 30, fontWeight: '900', color: '#172036' },
  parentCopy: { marginTop: 7, fontSize: 16, lineHeight: 22, color: '#667085', textAlign: 'center' },
  mathQuestion: { marginTop: 14, fontSize: 35, fontWeight: '900', color: '#172036' },
  numberGrid: { marginTop: 14, width: 390, flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', gap: 8 },
  numberButton: { width: 66, height: 48, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: '#eef2f8' },
  numberButtonText: { fontSize: 22, fontWeight: '900', color: '#172036' },
  errorText: { marginTop: 10, color: '#c4320a', fontWeight: '800' },
  cancelText: { marginTop: 13, color: '#667085', fontWeight: '800' },
  settingsList: { width: '100%', marginTop: 12, gap: 4 },
  settingRow: { minHeight: 48, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#d0d5dd' },
  settingLabel: { fontSize: 17, fontWeight: '800', color: '#344054' },
  resetButton: { marginTop: 12, paddingVertical: 12, borderRadius: 12, alignItems: 'center', backgroundColor: '#fff1f0' },
  resetButtonText: { color: '#b42318', fontWeight: '900' },
  phaseNote: { marginTop: 10, color: '#667085', textAlign: 'center', fontSize: 13 },
  purchaseHeadline: { marginTop: 18, fontSize: 22, fontWeight: '900', color: '#172036', textAlign: 'center', textTransform: 'uppercase' },
  disabledPurchase: { marginTop: 20, paddingHorizontal: 22, paddingVertical: 13, borderRadius: 999, backgroundColor: '#e9edf5' },
  disabledPurchaseText: { color: '#667085', fontWeight: '900' },
  primaryClose: { marginTop: 18, paddingHorizontal: 30, paddingVertical: 12, borderRadius: 999, backgroundColor: '#1a2c71' },
  primaryCloseText: { color: 'white', fontWeight: '900', fontSize: 16 },
});
