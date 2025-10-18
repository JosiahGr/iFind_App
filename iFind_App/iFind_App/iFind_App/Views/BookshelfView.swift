import SwiftUI

struct BookshelfView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var openBook = false
    @State private var pressedIndex: Int? = nil
    @State private var currentBookTitle: String = ""   // <-- NEW

    var body: some View {
        if openBook {
            BookView(bookTitle: currentBookTitle, onBack: { withAnimation(.none) { openBook = false } })
                .ignoresSafeArea()
                .transaction { $0.animation = nil }
        } else {
            ZStack {
                Image("bookshelfView_container")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 36) {

                        // 1 — Animals (unlocked)
                        BookshelfCard(title: "Animals",
                                      imageName: "animals_container",
                                      isLocked: false)
                            .onTapGesture {
                                withAnimation(.none) {
                                    currentBookTitle = "Animals"   // <-- NEW
                                    openBook = true
                                }
                            }
                            .pressToScale { pressing in pressedIndex = pressing ? 1 : nil }
                            .bobbing(amplitude: 5, period: 3.4, phase: 0.0,
                                     paused: openBook || pressedIndex == 1)

                        // 2 — Coming Soon (locked)
                        BookshelfCard(title: "Coming Soon",
                                      imageName: "bookshelfView_container",
                                      isLocked: true)
                            .pressToScale { pressing in pressedIndex = pressing ? 2 : nil }
                            .bobbing(amplitude: 5, period: 3.4, phase: 0.4,
                                     paused: openBook || pressedIndex == 2)

                        // 3 — Coming Soon (locked)
                        BookshelfCard(title: "Coming Soon",
                                      imageName: "bookshelfView_container",
                                      isLocked: true)
                            .pressToScale { pressing in pressedIndex = pressing ? 3 : nil }
                            .bobbing(amplitude: 5, period: 3.4, phase: 0.8,
                                     paused: openBook || pressedIndex == 3)
                    }
                    .padding(.leading, 124)
                    .padding(.trailing, 40)
                    .padding(.top, 72)
                    .padding(.bottom, 24)
                }

                // Slide to Home (top right)
                VStack {
                    HStack {

                        SlideToHomeButton { goBack() }
                            .frame(width: 180)
                            .padding(.leading, 20)
                            .padding(.top, 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }

    private func goBack() {
        if let onBack { onBack() } else { dismiss() }
    }
}

// MARK: - BookshelfCard (unchanged)
private struct BookshelfCard: View {
    let title: String
    let imageName: String
    let isLocked: Bool

    private let size = CGSize(width: 280, height: 220)
    private let corner: CGFloat = 12
    private let borderWidth: CGFloat = 24
    private let badgeHeight: CGFloat = 32

    var body: some View {
        VStack(spacing: 10) {
            // Image container
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .overlay {
                        if isLocked {
                            RoundedRectangle(cornerRadius: corner)
                                .fill(Color.black.opacity(0.35))
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: corner)
                            .stroke(.black, lineWidth: borderWidth)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: corner))
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                // Title overlays the container
                VStack {
                    Spacer().frame(height: size.height / 3.0)
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(isLocked ? .white : .black)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(width: size.width, height: size.height, alignment: .top)
            }

            // Locked pill below the container
            Group {
                if isLocked {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill").font(.title2.bold())
                        Text("Locked").font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.6), in: Capsule())
                    .shadow(radius: 4, y: 2)
                } else {
                    // Keep heights consistent across cards
                    Color.clear.frame(height: badgeHeight)
                }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: corner))
    }
}

#Preview("BookshelfView – Landscape Left", traits: .landscapeLeft) {
    BookshelfView()
}
