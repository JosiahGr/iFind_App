import SwiftUI

struct ParentAuthView: View {
    var onSuccess: () -> Void
    var onCancel: (() -> Void)? = nil
    var dimOpacity: Double = 0.4

    @State private var prompt = MathPrompt.random()
    @State private var showError = false

    var body: some View {
        ZStack {
            // ✅ Transparent dimmed background (modal style)
            Color.black.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { onCancel?() }

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Parents Only")
                        .font(.title).bold()
                    Spacer()
                    Button {
                        onCancel?()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.circle.fill)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }

                Text("To continue, please enter the correct answer.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text(prompt.question)
                    .font(.system(size: 36, weight: .bold))
                    .padding(.vertical, 6)

                // Keypad
                VStack(spacing: 14) {
                    KeypadRow(numbers: [1,2,3,4,5], tap: handleTap)
                    KeypadRow(numbers: [6,7,8,9,0], tap: handleTap)
                }
                .padding(.top, 8)

                if showError {
                    Text("Incorrect answer. Try again.")
                        .foregroundStyle(.red)
                        .font(.subheadline.weight(.semibold))
                        .transition(.opacity)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 2)
            )
            .frame(maxWidth: 480)
            .multilineTextAlignment(.center)
            .padding()
        }
        .presentationBackground(.clear)
    }

    private func handleTap(_ value: Int) {
        if value == prompt.answer {
            withAnimation(.easeInOut(duration: 0.15)) { showError = false }
            onSuccess()
        } else {
            withAnimation(.easeInOut(duration: 0.15)) { showError = true }
            prompt = .random() // regenerate new equation for retry
        }
    }
}

// MARK: - Supporting Views

private struct KeypadRow: View {
    let numbers: [Int]
    var tap: (Int) -> Void

    var body: some View {
        HStack(spacing: 14) {
            ForEach(numbers, id: \.self) { n in
                NumberPadButton(label: "\(n)") { tap(n) }
            }
        }
    }
}

private struct NumberPadButton: View {
    let label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.blue))
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Math Prompt
private struct MathPrompt {
    let a: Int
    let b: Int
    let op: Operation
    enum Operation: String { case plus = "+", minus = "-" }

    var question: String { "\(a) \(op.rawValue) \(b) = ?" }
    var answer: Int {
        switch op {
        case .plus:  return a + b
        case .minus: return a - b
        }
    }

    static func random() -> MathPrompt {
        let op: Operation = Bool.random() ? .plus : .minus
        switch op {
        case .plus:
            let a = Int.random(in: 0...9)
            let b = Int.random(in: 0...(9 - a))
            return MathPrompt(a: a, b: b, op: .plus)
        case .minus:
            let a = Int.random(in: 0...9)
            let b = Int.random(in: 0...a)
            return MathPrompt(a: a, b: b, op: .minus)
        }
    }
}

// MARK: - Preview
#Preview("Parent Auth Modal") {
    ZStack {
        Image("dashboardView_wallpaper")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ParentAuthView(onSuccess: {}, onCancel: {})
    }
}
