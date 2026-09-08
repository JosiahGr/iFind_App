import React, { useEffect, useState } from 'react';
import {
  Modal,
  Pressable,
  StyleSheet,
  Switch,
  Text,
  View,
} from 'react-native';

export type ParentDestination = 'settings' | 'purchase' | null;

type Settings = {
  music: boolean;
  sfx: boolean;
  timer: boolean;
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

export function ParentGate({
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

export function ParentPanel({
  destination,
  settings,
  onSettingChange,
  onResetProgress,
  onClose,
}: {
  destination: ParentDestination;
  settings: Settings;
  onSettingChange: (key: keyof Settings, value: boolean) => void;
  onResetProgress: () => void;
  onClose: () => void;
}) {
  const [resetStep, setResetStep] = useState<'idle' | 'confirm' | 'done'>('idle');

  useEffect(() => setResetStep('idle'), [destination]);

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

              {resetStep === 'idle' ? (
                <Pressable style={styles.resetButton} onPress={() => setResetStep('confirm')}>
                  <Text style={styles.resetButtonText}>Reset progress</Text>
                </Pressable>
              ) : null}

              {resetStep === 'confirm' ? (
                <View style={styles.confirmCard}>
                  <Text style={styles.confirmTitle}>Reset all book progress?</Text>
                  <Text style={styles.confirmCopy}>Completed pages will be cleared from this device. This cannot be undone.</Text>
                  <View style={styles.confirmActions}>
                    <Pressable style={styles.cancelResetButton} onPress={() => setResetStep('idle')}>
                      <Text style={styles.cancelResetText}>Keep progress</Text>
                    </Pressable>
                    <Pressable
                      style={styles.confirmResetButton}
                      onPress={() => {
                        onResetProgress();
                        setResetStep('done');
                      }}
                    >
                      <Text style={styles.confirmResetText}>RESET PROGRESS</Text>
                    </Pressable>
                  </View>
                </View>
              ) : null}

              {resetStep === 'done' ? (
                <View style={styles.resetDoneCard}>
                  <Text style={styles.resetDoneText}>Progress reset ✓</Text>
                  <Pressable onPress={() => setResetStep('idle')}>
                    <Text style={styles.resetAgainText}>Reset again</Text>
                  </Pressable>
                </View>
              ) : null}

              <Text style={styles.phaseNote}>Progress and preferences save on this device.</Text>
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
  modalScrim: {
    flex: 1,
    backgroundColor: 'rgba(10,16,30,0.55)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  parentCard: {
    width: 520,
    maxHeight: '92%',
    padding: 26,
    borderRadius: 26,
    backgroundColor: 'white',
    alignItems: 'center',
  },
  parentTitle: { fontSize: 30, fontWeight: '900', color: '#172036' },
  parentCopy: { marginTop: 7, fontSize: 16, lineHeight: 22, color: '#667085', textAlign: 'center' },
  mathQuestion: { marginTop: 14, fontSize: 35, fontWeight: '900', color: '#172036' },
  numberGrid: {
    marginTop: 14,
    width: 390,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 8,
  },
  numberButton: {
    width: 66,
    height: 48,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#eef2f8',
  },
  numberButtonText: { fontSize: 22, fontWeight: '900', color: '#172036' },
  errorText: { marginTop: 10, color: '#c4320a', fontWeight: '800' },
  cancelText: { marginTop: 13, color: '#667085', fontWeight: '800' },
  settingsList: { width: '100%', marginTop: 12, gap: 4 },
  settingRow: {
    minHeight: 48,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#d0d5dd',
  },
  settingLabel: { fontSize: 17, fontWeight: '800', color: '#344054' },
  resetButton: {
    marginTop: 12,
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
    backgroundColor: '#fff1f0',
  },
  resetButtonText: { color: '#b42318', fontWeight: '900' },
  confirmCard: {
    marginTop: 12,
    padding: 14,
    borderRadius: 14,
    backgroundColor: '#fff7ed',
    borderWidth: 1,
    borderColor: '#fed7aa',
  },
  confirmTitle: { color: '#9a3412', fontWeight: '900', fontSize: 17, textAlign: 'center' },
  confirmCopy: { color: '#7c2d12', fontSize: 13, lineHeight: 18, textAlign: 'center', marginTop: 5 },
  confirmActions: { flexDirection: 'row', justifyContent: 'center', gap: 10, marginTop: 12 },
  cancelResetButton: { paddingHorizontal: 14, paddingVertical: 9, borderRadius: 10, backgroundColor: 'white' },
  cancelResetText: { color: '#344054', fontWeight: '800' },
  confirmResetButton: { paddingHorizontal: 14, paddingVertical: 9, borderRadius: 10, backgroundColor: '#b42318' },
  confirmResetText: { color: 'white', fontWeight: '900', fontSize: 12 },
  resetDoneCard: { marginTop: 12, alignItems: 'center', padding: 10, borderRadius: 12, backgroundColor: '#ecfdf3' },
  resetDoneText: { color: '#027a48', fontWeight: '900' },
  resetAgainText: { color: '#667085', fontSize: 12, fontWeight: '800', marginTop: 4 },
  phaseNote: { marginTop: 10, color: '#667085', textAlign: 'center', fontSize: 13 },
  purchaseHeadline: {
    marginTop: 18,
    fontSize: 22,
    fontWeight: '900',
    color: '#172036',
    textAlign: 'center',
    textTransform: 'uppercase',
  },
  disabledPurchase: {
    marginTop: 20,
    paddingHorizontal: 22,
    paddingVertical: 13,
    borderRadius: 999,
    backgroundColor: '#e9edf5',
  },
  disabledPurchaseText: { color: '#667085', fontWeight: '900' },
  primaryClose: {
    marginTop: 18,
    paddingHorizontal: 30,
    paddingVertical: 12,
    borderRadius: 999,
    backgroundColor: '#1a2c71',
  },
  primaryCloseText: { color: 'white', fontWeight: '900', fontSize: 16 },
});
