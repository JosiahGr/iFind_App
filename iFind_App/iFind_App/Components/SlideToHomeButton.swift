import SwiftUI

struct SlideToHomeButton: View {
    var onSlideComplete: () -> Void
    var slideDistance: CGFloat = 96
    var knobSize: CGFloat = 38

    var body: some View {
        SlideControl(
            systemIcon: "house.fill",
            onSlideComplete: onSlideComplete,
            slideDistance: slideDistance,
            knobSize: knobSize
        )
    }
}

#Preview {
    ZStack {
        Color.orange.ignoresSafeArea()
        SlideToHomeButton { print("Home triggered!") }
            .padding()
    }
}
