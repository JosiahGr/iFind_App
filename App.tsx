import React, { useEffect, useState } from 'react';
import {
  Image,
  ImageBackground,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  type ImageSourcePropType,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { ParentGate, ParentPanel, type ParentDestination } from './src/components/ParentControls';
import { SceneGame } from './src/components/SceneGame';
import { animalsBook, type BookDefinition, type PageDefinition } from './src/data/catalog';
import type { Level } from './src/data/levels';
import { AppStateProvider, useAppState } from './src/state/AppStateContext';

type Screen = 'splash' | 'dashboard' | 'bookshelf' | 'book' | 'game';
type PageStatus = 'available' | 'completed' | 'locked' | 'upcoming';

const art = {
  splash: require('./assets/splash.png'),
  dashboard: require('./assets/dashboard.png'),
  bookshelf: require('./assets/bookshelf.png'),
  bookshelfCard: require('./assets/bookshelf-card.png'),
};

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

function pageStatus(
  book: BookDefinition,
  page: PageDefinition,
  index: number,
  completedLevelIds: string[],
): PageStatus {
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
          const canOpen = page.level && (status === 'available' || status === 'completed');

          return (
            <PageCard
              key={page.id}
              page={page}
              status={status}
              onPress={canOpen ? () => onOpenLevel(page.level!) : undefined}
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
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
      onPress={onPress}
      style={styles.roundButton}
    >
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

const styles = StyleSheet.create({
  app: { flex: 1, backgroundColor: '#101a35' },
  screen: { flex: 1 },
  fullImage: { width: '100%', height: '100%' },
  parentButtons: {
    position: 'absolute',
    top: 18,
    right: 24,
    zIndex: 5,
    flexDirection: 'row',
    gap: 10,
  },
  roundButton: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.9)',
  },
  roundButtonText: { fontSize: 24 },
  dashboardCard: {
    position: 'absolute',
    alignSelf: 'center',
    top: '23%',
    width: 350,
    height: 255,
    borderRadius: 24,
    overflow: 'hidden',
    borderWidth: 12,
    borderColor: 'rgba(255,255,255,0.88)',
  },
  dashboardCardImage: { width: '100%', height: '100%' },
  cardShade: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(0,0,0,0.12)' },
  dashboardCardTitle: {
    position: 'absolute',
    alignSelf: 'center',
    top: '34%',
    color: 'white',
    fontSize: 40,
    fontWeight: '900',
    textShadowColor: 'rgba(0,0,0,0.45)',
    textShadowRadius: 5,
  },
  dashboardCardCopy: {
    position: 'absolute',
    alignSelf: 'center',
    top: '58%',
    color: 'white',
    fontSize: 15,
    fontWeight: '800',
    textShadowColor: 'rgba(0,0,0,0.45)',
    textShadowRadius: 4,
  },
  topBar: {
    position: 'absolute',
    top: 18,
    left: 28,
    right: 28,
    zIndex: 5,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  backCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#1a2c71',
    alignItems: 'center',
    justifyContent: 'center',
  },
  backCircleText: { color: 'white', fontSize: 38, lineHeight: 40, fontWeight: '800', marginTop: -3 },
  topTitle: { fontSize: 36, fontWeight: '900', color: '#172036' },
  bookRow: { paddingTop: 115, paddingHorizontal: 84, paddingBottom: 30, gap: 34, alignItems: 'center' },
  bookCardWrap: { alignItems: 'center', width: 270 },
  bookCard: {
    width: 260,
    height: 205,
    borderRadius: 18,
    overflow: 'hidden',
    borderWidth: 10,
    borderColor: '#111827',
    backgroundColor: 'white',
  },
  bookCardImage: { width: '100%', height: '100%' },
  lockShade: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(0,0,0,0.44)' },
  bookTitle: {
    position: 'absolute',
    alignSelf: 'center',
    top: '40%',
    fontSize: 28,
    fontWeight: '900',
    color: '#111827',
    textShadowColor: 'white',
    textShadowRadius: 4,
  },
  lockedTitle: { color: 'white', textShadowColor: 'rgba(0,0,0,0.4)' },
  bookBadge: {
    marginTop: 12,
    paddingHorizontal: 14,
    paddingVertical: 7,
    overflow: 'hidden',
    borderRadius: 999,
    backgroundColor: 'rgba(17,24,39,0.8)',
    color: 'white',
    fontWeight: '800',
  },
  lightWash: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(255,255,255,0.46)' },
  pageRow: { paddingTop: 112, paddingHorizontal: 70, paddingBottom: 30, gap: 26, alignItems: 'center' },
  pageCard: {
    width: 164,
    height: 218,
    borderRadius: 18,
    overflow: 'hidden',
    borderWidth: 9,
    backgroundColor: '#fff',
    alignItems: 'center',
  },
  pageAvailable: { borderColor: '#3d8ef7' },
  pageCompleted: { borderColor: '#22a06b' },
  pageLocked: { borderColor: '#f1cf3f' },
  pageImage: { width: '100%', height: '100%' },
  pageLockShade: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(0,0,0,0.38)' },
  pageTitle: {
    position: 'absolute',
    top: 76,
    fontSize: 18,
    fontWeight: '900',
    color: '#111827',
    backgroundColor: 'rgba(255,255,255,0.78)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
  },
  pageStatusBadge: {
    position: 'absolute',
    bottom: 10,
    minWidth: 42,
    minHeight: 34,
    paddingHorizontal: 8,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.9)',
  },
  pageStatusComplete: { backgroundColor: 'rgba(224,250,239,0.96)' },
  pageStatusText: { fontSize: 18, fontWeight: '900', color: '#172036' },
});
