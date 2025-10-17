import SwiftUI

struct Bobbing: ViewModifier {
    var amplitude: CGFloat = 5      // travel in points
    var period: Double = 1.4        // seconds for a full up-down
    var phase: Double = 0.0         // start delay to desync items
    var paused: Bool = false        // pause control

    @State private var up = false

    func body(content: Content) -> some View {
        content
            // center when paused
            .offset(y: paused ? 0 : (up ? -amplitude : amplitude))
            .animation(
                paused
                ? nil
                : .easeInOut(duration: period)
                    .delay(phase)
                    .repeatForever(autoreverses: true),
                value: up
            )
            .onAppear {
                guard !paused else { return }
                up = true
            }
            .onChange(of: paused) { _, isPaused in
                if isPaused {
                    // stop and recenter
                    up = false
                } else {
                    // resume the repeating animation
                    up = true
                }
            }
    }
}

extension View {
    func bobbing(
        amplitude: CGFloat = 5,
        period: Double = 3.4,
        phase: Double = 0,
        paused: Bool = false
    ) -> some View {
        modifier(Bobbing(amplitude: amplitude, period: period, phase: phase, paused: paused))
    }
}
