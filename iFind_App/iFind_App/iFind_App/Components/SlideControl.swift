import SwiftUI

/// Reusable right-to-left slide control
struct SlideControl: View {
    // Config
    var systemIcon: String
    var onSlideComplete: () -> Void
    var slideDistance: CGFloat = 96
    var knobSize: CGFloat = 32
    var enableHaptics: Bool = true

    // Visual style
    private let strokeWidth: CGFloat = 2
    private let innerPadding: CGFloat = 4
    private let strokeColor = Color(red: 1.0, green: 0.88, blue: 0.64)
    private let targetColor = Color(red: 1.0, green: 0.88, blue: 0.64)
    private let knobColor   = Color(red: 0.10, green: 0.10, blue: 0.35)

    // State
    @State private var dragOffset: CGFloat = 0
    @State private var isTriggered = false

    // Derived sizes
    private var trackWidth: CGFloat { slideDistance + knobSize + 10 }
    private var trackHeight: CGFloat { knobSize + 6 }

    var body: some View {
        ZStack {
            // Track
            Capsule()
                .stroke(strokeColor, lineWidth: strokeWidth)
                .frame(width: trackWidth, height: trackHeight)

            // Layout all parts relative to capsule
            GeometryReader { g in
                let W = g.size.width
                let H = g.size.height

                let targetCenterX = innerPadding + knobSize / 2
                let knobStartCenterX = W - innerPadding - knobSize / 2
                let knobCenterX = knobStartCenterX + dragOffset

                // Target circle on the left
                Circle()
                    .fill(targetColor)
                    .frame(width: knobSize, height: knobSize)
                    .position(x: targetCenterX, y: H / 2)

                // Arrow hint at midpoint between target and knob
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(strokeColor)
                    .position(x: (targetCenterX + knobCenterX) / 2, y: H / 2)
                    .allowsHitTesting(false)
                    .zIndex(1)

                // Draggable knob on the right
                Circle()
                    .fill(knobColor)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Image(systemName: systemIcon)
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .bold))
                    )
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                    .position(x: knobCenterX, y: H / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Clamp to the visual travel only
                                dragOffset = max(-slideDistance, min(0, value.translation.width))
                            }
                            .onEnded { value in
                                if abs(value.translation.width) > slideDistance * 0.75 {
                                    // Success
                                    if enableHaptics { Haptics.unlockPulse() }
                                    withAnimation(.spring(response: 0.30, dampingFraction: 0.80)) {
                                        dragOffset = -slideDistance
                                        isTriggered = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        onSlideComplete()
                                        reset()
                                    }
                                } else {
                                    // Snap back
                                    if enableHaptics { Haptics.snapBack() }
                                    withAnimation(.spring()) { dragOffset = 0 }
                                }
                            }
                    )
                    .zIndex(2)
            }
            .frame(width: trackWidth, height: trackHeight)
        }
        .frame(width: trackWidth, height: trackHeight)
        .contentShape(Capsule())
    }

    private func reset() {
        isTriggered = false
        dragOffset = 0
    }
}

#Preview("SlideControl") {
    ZStack {
        Color(red: 1.0, green: 0.67, blue: 0.25).ignoresSafeArea()
        SlideControl(systemIcon: "house.fill") { print("Complete") }
            .padding()
    }
}
