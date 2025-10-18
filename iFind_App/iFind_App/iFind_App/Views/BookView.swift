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
                            openAnimalsLevel() // uses Animals-05 + 6 targets
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

    // MARK: - Level using animals_wallpaper (1664 × 768) with refined hit boxes
    private func openAnimalsLevel() {
        // Exact pixel size of the asset in your xcassets
        let sceneSize = CGSize(width: 1664, height: 768)

        // Helper to convert percentage-based rects (0...1) into pixel-space rects
        func pxRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            return CGRect(x: x * sceneSize.width,
                          y: y * sceneSize.height,
                          width:  w * sceneSize.width,
                          height: h * sceneSize.height)
        }

        // Bear → Bird → Penguin → Lion → Monkey → Rabbit
        // Percentages are measured in ORIGINAL image space (top-left origin).
        // These are generous kid-friendly boxes aligned to your Animals-05 layout.
        let targets: [PageTarget] = [
            PageTarget(
                imageName: "thumb_bear",
                // left ~6%, top ~69%, width ~15%, height ~28%
                hitRect: pxRect(0.060, 0.690, 0.150, 0.280),
                accessibilityLabel: "Bear"
            ),
            PageTarget(
                imageName: "thumb_bird",
                // left ~26%, top ~69%, width ~14%, height ~28%
                hitRect: pxRect(0.260, 0.690, 0.150, 0.280),
                accessibilityLabel: "Bird"
            ),
            PageTarget(
                imageName: "thumb_penguin",
                // left ~46.5%, top ~67%, width ~14.5%, height ~30%
                hitRect: pxRect(0.40, 0.690, 0.150, 0.280),
                accessibilityLabel: "Penguin"
            ),
            PageTarget(
                imageName: "thumb_lion",
                // left ~62.5%, top ~66.5%, width ~15%, height ~30%
                hitRect: pxRect(0.54, 0.69, 0.150, 0.280),
                accessibilityLabel: "Lion"
            ),
            PageTarget(
                imageName: "thumb_monkey",
                // left ~78.5%, top ~65.5%, width ~14%, height ~31%
                hitRect: pxRect(0.64, 0.69, 0.150, 0.280),
                accessibilityLabel: "Monkey"
            ),
            PageTarget(
                imageName: "thumb_rabbit",
                // left ~90.7%, top ~68%, width ~8.8%, height ~27%
                hitRect: pxRect(0.84, 0.690, 0.15, 0.280),
                accessibilityLabel: "Rabbit"
            )
        ]

        let level = PageLevel(
            sceneImageName: "animals_wallpaper", // your asset name
            sceneImageSize: sceneSize,
            targets: targets
        )

        selectedLevel = level
        openPage = true
    }
}
