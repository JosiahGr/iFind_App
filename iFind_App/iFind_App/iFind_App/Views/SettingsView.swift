import SwiftUI

struct SettingsView: View {
    // Callbacks
    var didClose: () -> Void
    var onResetProgress: (() -> Void)? = nil
    var onRestorePurchases: (() -> Void)? = nil
    var dimOpacity: Double = 0.4

    // Local state (replace later with shared AppState if desired)
    @State private var musicOn = true
    @State private var sfxOn   = true
    @State private var timerOn = false

    var body: some View {
        ZStack {
            // Dimmed overlay (tap outside to dismiss)
            Color.black.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { didClose() }

            // Card
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.title).bold()
                    Spacer()
                    Button(action: didClose) {
                        Image(systemName: "xmark")
                            .symbolVariant(.circle.fill)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }

                // Toggles
                VStack(spacing: 16) {
                    Toggle(isOn: $musicOn) {
                        Text("Music").font(.title3)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))

                    Toggle(isOn: $sfxOn) {
                        Text("Sound effects").font(.title3)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))

                    Toggle(isOn: $timerOn) {
                        Text("15 minute timer").font(.title3)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding(.top, 4)

                // Reset
                Button(role: .destructive) {
                    onResetProgress?()
                } label: {
                    Text("Reset Progress")
                        .font(.body.weight(.semibold))
                }
                .padding(.top, 8)

                // Footer: Restore Purchases
                Button {
                    onRestorePurchases?()
                } label: {
                    Text("Restore purchases")
                        .font(.callout.weight(.semibold))
                }
                .padding(.top, 6)
                .foregroundStyle(.secondary)

            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .frame(maxWidth: 480)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 2)
            )
            .multilineTextAlignment(.leading)
        }
        // Make the system sheet background transparent so our dim shows
        .presentationBackground(.clear)
    }
}

#Preview("Settings Modal") {
    ZStack {
        Color.orange.ignoresSafeArea()
        SettingsView(didClose: {})
            .padding()
    }
}
