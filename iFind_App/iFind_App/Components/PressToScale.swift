import SwiftUI

struct PressToScale: ViewModifier {
    var scale: CGFloat = 0.98
    var onChange: (Bool) -> Void = { _ in }

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: isPressed)
            // Track press state without consuming the tap
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
                onChange(pressing)
            }, perform: {})
    }
}

extension View {
    func pressToScale(_ scale: CGFloat = 0.98,
                      onChange: @escaping (Bool) -> Void = { _ in }) -> some View {
        modifier(PressToScale(scale: scale, onChange: onChange))
    }
}
