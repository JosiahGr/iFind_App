import SwiftUI

struct SlideToHomeButton: View {
    var onSlideComplete: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isTriggered = false

    private let totalSlide: CGFloat = 120 // how far left it must slide
    private let buttonSize: CGFloat = 48

    var body: some View {
        ZStack(alignment: .trailing) {
            // Background track
            RoundedRectangle(cornerRadius: buttonSize / 2)
                .fill(Color.gray.opacity(0.15))
                .frame(width: totalSlide + buttonSize + 20, height: buttonSize - 8)
                .overlay(
                    Text("Slide to Home")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.gray.opacity(0.6))
                        .offset(x: -20)
                )

            // Draggable home button (starts aligned to right edge)
            Circle()
                .fill(Color(red: 0.0, green: 0.14, blue: 0.31))
                .frame(width: buttonSize, height: buttonSize)
                .overlay(
                    Image(systemName: "house.fill")
                        .foregroundStyle(.white)
                        .font(.title2.bold())
                )
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Move left only, clamped to -totalSlide
                            dragOffset = max(-totalSlide, min(0, value.translation.width))
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > totalSlide * 0.75 {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    dragOffset = -totalSlide
                                    isTriggered = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    onSlideComplete()
                                    reset()
                                }
                            } else {
                                // Slide too short → snap back
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                // ✅ Start flush right, move left as dragged
                .padding(.trailing, 4)
        }
        .frame(height: buttonSize)
    }

    private func reset() {
        isTriggered = false
        dragOffset = 0
    }
}

#Preview("Slide To Home Button (Right Start)") {
    ZStack {
        Color.orange.ignoresSafeArea()
        SlideToHomeButton {
            print("Home triggered!")
        }
        .padding()
    }
}
