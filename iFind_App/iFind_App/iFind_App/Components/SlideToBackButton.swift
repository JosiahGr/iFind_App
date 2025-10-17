import SwiftUI

struct SlideToBackButton: View {
    var onSlideComplete: () -> Void
    var slideDistance: CGFloat = 96
    var knobSize: CGFloat = 32

    var body: some View {
        SlideControl(
            systemIcon: "chevron.left",
            onSlideComplete: onSlideComplete,
            slideDistance: slideDistance,
            knobSize: knobSize
        )
    }
}

#Preview {
    ZStack {
        Color.yellow.ignoresSafeArea()
        SlideToBackButton { print("Back triggered!") }
            .padding()
    }
}
