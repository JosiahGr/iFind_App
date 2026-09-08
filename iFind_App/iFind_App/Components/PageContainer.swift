import SwiftUI

struct PageContainer: View {
    let title: String
    let imageName: String
    let status: PageStatus

    var onOpen: (() -> Void)?          // tap when available/completed
    var onLocked: (() -> Void)?        // tap when locked

    // Style constants (match Bookshelf)
    private let size = CGSize(width: 280, height: 220)
    private let corner: CGFloat = 12
    private let borderWidth: CGFloat = 24

    var body: some View {
        Button {
            switch status {
            case .available, .completed:
                onOpen?()
            case .locked:
                onLocked?()
            }
        } label: {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .cornerRadius(corner)

                    // Dim only when locked (inside the clip)
                    .overlay {
                        if status == .locked {
                            RoundedRectangle(cornerRadius: corner)
                                .fill(Color.black.opacity(0.35))
                        }
                    }

                    // Outside border
                    .overlay(
                        RoundedRectangle(cornerRadius: corner + borderWidth / 2)
                            .stroke(Color.black, lineWidth: borderWidth)
                            .padding(-borderWidth / 2)
                    )

                    .clipShape(RoundedRectangle(cornerRadius: corner))
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                VStack {
                    Spacer().frame(height: size.height / 3.0)
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(status == .locked ? .white : .black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    Spacer()
                }
                .frame(width: size.width, height: size.height, alignment: .top)

                if status == .completed {
                    Image("finished_banner")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * 0.95)
                        .rotationEffect(.degrees(-8))
                        .offset(y: -10)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: corner))
        }
        .buttonStyle(.plain)
        .padding(10)
    }
}

#Preview("PageContainer – Landscape", traits: .landscapeLeft) {
    HStack(spacing: 30) {
        PageContainer(title: "Page 1", imageName: "animals_container", status: .available, onOpen: {}, onLocked: {})
        PageContainer(title: "Page 2", imageName: "animals_container", status: .completed, onOpen: {}, onLocked: {})
        PageContainer(title: "New Pack", imageName: "animals_container", status: .locked, onOpen: {}, onLocked: {})
    }
    .padding()
}

