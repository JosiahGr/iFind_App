import SwiftUI

struct BookshelfView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var openBook = false  // opens the unlocked book

    var body: some View {
        if openBook {
            BookView()
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
                        BookshelfCard(
                            title: "Animals",
                            imageName: "animals_container",
                            isLocked: false
                        )
                        .onTapGesture { withAnimation(.none) { openBook = true } }

                        BookshelfCard(
                            title: "Coming Soon",
                            imageName: "bookshelfView_wallpaper",
                            isLocked: true
                        )

                        BookshelfCard(
                            title: "Coming Soon",
                            imageName: "bookshelfView_wallpaper",
                            isLocked: true
                        )
                    }
                    .padding(.leading, 124)
                    .padding(.trailing, 40)
                    .padding(.top, 72)
                    .padding(.bottom, 24)
                }

                VStack {
                    HStack {
                        Spacer()
                        SlideToHomeButton { goBack() }
                            .frame(width: 180)
                            .padding(.trailing, 32)
                            .padding(.top, 12)
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

private struct BookshelfCard: View {
    let title: String
    let imageName: String
    let isLocked: Bool

    private let size = CGSize(width: 280, height: 220)
    private let corner: CGFloat = 5
    private let borderWidth: CGFloat = 24
    private let badgeHeight: CGFloat = 32

    var body: some View {
        VStack(spacing: 8) {
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
                Color.clear.frame(height: badgeHeight)
            }

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
        }
        .contentShape(RoundedRectangle(cornerRadius: corner))
    }
}

#Preview("BookshelfView – Landscape", traits: .landscapeLeft) {
    BookshelfView()
}
