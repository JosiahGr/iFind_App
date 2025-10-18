import SwiftUI

public struct PageCard: View {
    public let title: String
    public let imageName: String
    public let status: PageStatus
    public var cardSize: CGSize = CGSize(width: 160, height: 200)

    // Status colors that also tint the border
    private var borderColor: Color {
        switch status {
        case .locked:    return Color(red: 1.0, green: 0.85, blue: 0.20) // gold
        case .available: return Color(red: 0.15, green: 0.55, blue: 1.00) // blue
        case .completed: return Color(red: 0.20, green: 0.70, blue: 0.30) // green
        }
    }

    // Derived from size
    private var corner: CGFloat { max(4, cardSize.width * 0.018) }
    private var borderWidth: CGFloat { max(6, cardSize.width * 0.085) }
    private var titleFont: Font { .system(size: max(12, cardSize.width * 0.10), weight: .bold) }
    private var spacingBelow: CGFloat { max(6, cardSize.height * 0.045) }

    public init(title: String,
                imageName: String,
                status: PageStatus,
                cardSize: CGSize = CGSize(width: 160, height: 200)) {
        self.title = title
        self.imageName = imageName
        self.status = status
        self.cardSize = cardSize
    }

    public var body: some View {
        VStack(spacing: spacingBelow) {
            ZStack {
                // Image content with rounded corners
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: corner))

                    // Dim overlay when locked
                    .overlay {
                        if status == .locked {
                            RoundedRectangle(cornerRadius: corner)
                                .fill(Color.black.opacity(0.35))
                        }
                    }

                    // Outer border behind the image (does not cover photo)
                    .background(
                        RoundedRectangle(cornerRadius: corner + borderWidth / 2)
                            .strokeBorder(borderColor.opacity(0.8), lineWidth: borderWidth)
                            .padding(-borderWidth / 2)
                    )

                    // Optional glossy highlight on top
                    .overlay(
                        RoundedRectangle(cornerRadius: corner + borderWidth / 2)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.65), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: borderWidth * 0.3
                            )
                            .padding(-borderWidth / 2)
                            .blendMode(.screen)
                            .opacity(0.7)
                    )

                    // Subtle shadow outside border
                    .shadow(color: borderColor.opacity(0.35), radius: 6, x: 0, y: 3)

                // Title overlay
                VStack {
                    Spacer().frame(height: cardSize.height / 3.0)
                    Text(title)
                        .font(titleFont)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(width: cardSize.width, height: cardSize.height, alignment: .top)
            }

            // Icon-only status indicator below the card
            switch status {
            case .locked:
                PageStatusIcon(kind: .unlock)
            case .available:
                PageStatusIcon(kind: .play)
            case .completed:
                PageStatusIcon(kind: .completed)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: corner))
    }
}

// MARK: - PageStatusIcon

private struct PageStatusIcon: View {
    enum Kind { case unlock, play, completed }
    let kind: Kind

    private var icon: String {
        switch kind {
        case .unlock:    return "star.fill"
        case .play:      return "face.smiling"
        case .completed: return "checkmark.circle.fill"
        }
    }

    private var color: Color {
        switch kind {
        case .unlock:    return Color(red: 1.0, green: 0.85, blue: 0.20) // gold
        case .play:      return Color(red: 0.15, green: 0.55, blue: 1.00) // blue
        case .completed: return Color(red: 0.20, green: 0.70, blue: 0.30) // green
        }
    }

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(color, in: Circle())
            .shadow(color: color.opacity(0.35), radius: 4, y: 2)
            .accessibilityLabel(kind == .unlock ? "Unlock" : kind == .play ? "Play" : "Completed")
            .padding(.top, 16)
    }
}
