import SwiftUI
import SwiftUI

struct BookView: View {
    let bookTitle: String
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private enum OverlayRoute { case auth }
    @State private var overlayRoute: OverlayRoute? = nil
    @State private var pressedIndex: Int? = nil

    // Open PageView + selected level
    @State private var openPage = false
    @State private var selectedLevel: PageLevel? = nil

    // Around 65% of the old size
    private let cardSize = CGSize(width: 160, height: 200)

    // Navy color for back button
    private let navNavy = Color(red: 0.10, green: 0.17, blue: 0.45)

    var body: some View {
        ZStack {
            // Background (just a neutral backdrop here)
            Color.clear.ignoresSafeArea()

            // Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 28) {
                    ForEach(0..<10) { i in
                        let status: PageStatus =
                            (i == 0) ? .available :
                            (i == 1) ? .completed : .locked

                        PageCard(
                            title: "Page \(i + 1)",
                            imageName: "animals_container",
                            status: status,
                            cardSize: cardSize
                        )
                        // Open PageView only for non-locked pages
                        .onTapGesture {
                            guard status != .locked else { return }
                            openAnimalsLevel() // uses test_animals + 6 targets
                        }
                        .pressToScale { pressing in pressedIndex = pressing ? i : nil }
                        .bobbing(
                            amplitude: 5,
                            period: 3.4,
                            phase: Double(i) * 0.2,
                            paused: overlayRoute != nil || pressedIndex == i
                        )
                    }
                }
                .padding(.leading, 80)
                .padding(.trailing, 32)
                .padding(.top, 72)
                .padding(.bottom, 24)
            }

            // Top bar: Title and Back Chevron
            VStack {
                HStack(spacing: 24) {
                    Button {
                        if let onBack { onBack() } else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(navNavy, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .accessibilityLabel("Back")

                    Text(bookTitle)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer()
                }
                .padding(.leading, 40)
                .padding(.top, 20)

                Spacer()
            }
            .zIndex(2)
            .opacity(overlayRoute == nil ? 1 : 0)
            .allowsHitTesting(overlayRoute == nil)

            // Optional: parent auth overlay ONLY
            if let route = overlayRoute, route == .auth {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { overlayRoute = nil }

                    ParentAuthView(
                        onSuccess: { overlayRoute = nil },
                        onCancel:  { overlayRoute = nil },
                        dimOpacity: 0
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: overlayRoute)
            }
        }
        // Present the actual game page
        .fullScreenCover(isPresented: $openPage) {
            if let level = selectedLevel {
                PageView(level: level) {
                    openPage = false
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Level using test_animals (1664 × 768) with refined hit boxes
    private func openAnimalsLevel() {
        // Exact pixel size of your asset
        let sceneSize = CGSize(width: 1664, height: 768)

        // Helper: percentages (0...1) → pixel rects
        func pxRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: x * sceneSize.width,
                   y: y * sceneSize.height,
                   width:  w * sceneSize.width,
                   height: h * sceneSize.height)
        }

        // Order expected by your game: Bear → Bird → Penguin → Lion → Monkey → Rabbit
        // These percentages are tuned for the image you uploaded (top row: lion/penguin/monkey/rabbit; bottom row: bear/bird).
        // They’re generous for kid-friendly taps; nudge x/y/w/h by ±0.01–0.02 if you want tighter/looser boxes.
        let targets: [PageTarget] = [
            // BEAR – bottom-left/mid
            PageTarget(
                imageName: "test_bear",
                hitRect: pxRect(0.230, 0.58, 0.132, 0.339),
                accessibilityLabel: "Bear"
            ),
            // BIRD – bottom center
            PageTarget(
                imageName: "test_bird",
                hitRect: pxRect(0.48, 0.58, 0.132, 0.339),
                accessibilityLabel: "Bird"
            ),
            // PENGUIN – upper center
            PageTarget(
                imageName: "test_penguin",
                hitRect: pxRect(0.36, 0.08, 0.132, 0.339),
                accessibilityLabel: "Penguin"
            ),
            // LION – upper left
            PageTarget(
                imageName: "test_lion",
                hitRect: pxRect(0.087, 0.208, 0.132, 0.339),
                accessibilityLabel: "Lion"
            ),
            // MONKEY – upper right-mid
            PageTarget(
                imageName: "test_monkey",
                hitRect: pxRect(0.60, 0.142, 0.132, 0.339),
                accessibilityLabel: "Monkey"
            ),
            // RABBIT – far right
            PageTarget(
                imageName: "test_rabbit",
                hitRect: pxRect(0.859, 0.162, 0.132, 0.339),
                accessibilityLabel: "Rabbit"
            )
        ]

        let level = PageLevel(
            sceneImageName: "test_animals", // your full-background asset
            sceneImageSize: sceneSize,
            targets: targets
        )

        selectedLevel = level
        openPage = true
    }
}
