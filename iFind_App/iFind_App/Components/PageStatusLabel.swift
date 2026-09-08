import SwiftUI

private struct PageStatusLabel: View {
    enum Kind { case unlock, play, completed }
    let kind: Kind

    var body: some View {
        let (icon, color): (String, Color) = {
            switch kind {
            case .unlock:
                return ("star.fill", Color(red: 1.0, green: 0.85, blue: 0.2))      // gold
            case .play:
                return ("face.smiling", Color(red: 0.15, green: 0.55, blue: 1.0))  // blue
            case .completed:
                return ("checkmark.circle.fill", Color(red: 0.2, green: 0.7, blue: 0.3)) // green
            }
        }()

        Image(systemName: icon)
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(color, in: Circle())
            .shadow(color: color.opacity(0.4), radius: 4, y: 2)
            .accessibilityLabel(
                kind == .unlock ? "Unlock" :
                kind == .play ? "Let's Play" : "Completed"
            )
    }
}
