import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';

type Settings = {
  music: boolean;
  sfx: boolean;
  timer: boolean;
};

type PersistedState = {
  version: 1;
  completedLevelIds: string[];
  settings: Settings;
};

type AppStateContextValue = {
  hydrated: boolean;
  completedLevelIds: string[];
  settings: Settings;
  completeLevel: (levelId: string) => void;
  resetProgress: () => void;
  setSetting: (key: keyof Settings, value: boolean) => void;
};

const STORAGE_KEY = '@ifind/state/v1';

const DEFAULT_STATE: PersistedState = {
  version: 1,
  completedLevelIds: [],
  settings: {
    music: true,
    sfx: true,
    timer: false,
  },
};

const AppStateContext = createContext<AppStateContextValue | null>(null);

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<PersistedState>(DEFAULT_STATE);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    let mounted = true;

    async function hydrate() {
      try {
        const saved = await AsyncStorage.getItem(STORAGE_KEY);
        if (!saved || !mounted) return;

        const parsed = JSON.parse(saved) as Partial<PersistedState>;
        setState({
          ...DEFAULT_STATE,
          ...parsed,
          version: 1,
          completedLevelIds: Array.isArray(parsed.completedLevelIds)
            ? parsed.completedLevelIds
            : DEFAULT_STATE.completedLevelIds,
          settings: {
            ...DEFAULT_STATE.settings,
            ...(parsed.settings ?? {}),
          },
        });
      } catch (error) {
        console.warn('Unable to restore iFind state', error);
      } finally {
        if (mounted) setHydrated(true);
      }
    }

    void hydrate();
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    void AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(state)).catch((error) => {
      console.warn('Unable to save iFind state', error);
    });
  }, [hydrated, state]);

  const value = useMemo<AppStateContextValue>(
    () => ({
      hydrated,
      completedLevelIds: state.completedLevelIds,
      settings: state.settings,
      completeLevel(levelId) {
        setState((current) => {
          if (current.completedLevelIds.includes(levelId)) return current;
          return {
            ...current,
            completedLevelIds: [...current.completedLevelIds, levelId],
          };
        });
      },
      resetProgress() {
        setState((current) => ({ ...current, completedLevelIds: [] }));
      },
      setSetting(key, value) {
        setState((current) => ({
          ...current,
          settings: { ...current.settings, [key]: value },
        }));
      },
    }),
    [hydrated, state],
  );

  return <AppStateContext.Provider value={value}>{children}</AppStateContext.Provider>;
}

export function useAppState() {
  const context = useContext(AppStateContext);
  if (!context) {
    throw new Error('useAppState must be used inside AppStateProvider');
  }
  return context;
}
