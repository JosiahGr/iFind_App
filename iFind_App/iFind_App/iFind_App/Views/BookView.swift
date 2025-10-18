import SwiftUI

struct BookView: View {
    let bookTitle: String
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private enum OverlayRoute { case auth }
    @State private var overlayRoute: OverlayRoute? = nil
    @State private var pressedIndex: Int? = nil

    // NEW: open PageView + selected level
    @State private var openPage = false
    @State private var selectedLevel: PageLevel? = nil

    // Around 65% of the old size
    private let cardSize = CGSize(width: 160, height: 200)

    // Navy color for back button
    private let navNavy = Color(red: 0.10, green: 0.17, blue: 0.45)

    var body: some View {
        ZStack {
            // Background
            Image("animals_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.0)

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
                            openExampleLevel(pageIndex: i)
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

    // MARK: - Open a placeholder PageLevel (replace with your real data)
    private func openExampleLevel(pageIndex: Int) {
        // TODO: replace names/sizes with your real scene + 10 thumbnails
        let sceneSize = CGSize(width: 3840, height: 2160) // example 4K landscape

        let targets: [PageTarget] = [
            PageTarget(imageName: "thumb_1", hitRect: CGRect(x: 300,  y: 1450, width: 260, height: 220), accessibilityLabel: "Target 1"),
            PageTarget(imageName: "thumb_2", hitRect: CGRect(x: 760,  y: 980,  width: 240, height: 240), accessibilityLabel: "Target 2"),
            PageTarget(imageName: "thumb_3", hitRect: CGRect(x: 1180, y: 1360, width: 260, height: 220), accessibilityLabel: "Target 3"),
            PageTarget(imageName: "thumb_4", hitRect: CGRect(x: 1600, y: 820,  width: 240, height: 240), accessibilityLabel: "Target 4"),
            PageTarget(imageName: "thumb_5", hitRect: CGRect(x: 2020, y: 1200, width: 260, height: 220), accessibilityLabel: "Target 5"),
            PageTarget(imageName: "thumb_6", hitRect: CGRect(x: 2440, y: 940,  width: 240, height: 240), accessibilityLabel: "Target 6"),
            PageTarget(imageName: "thumb_7", hitRect: CGRect(x: 2860, y: 1480, width: 260, height: 220), accessibilityLabel: "Target 7"),
            PageTarget(imageName: "thumb_8", hitRect: CGRect(x: 3180, y: 760,  width: 240, height: 240), accessibilityLabel: "Target 8"),
            PageTarget(imageName: "thumb_9", hitRect: CGRect(x: 3400, y: 1260, width: 260, height: 220), accessibilityLabel: "Target 9"),
            PageTarget(imageName: "thumb_10",hitRect: CGRect(x: 3600, y: 880,  width: 220, height: 220), accessibilityLabel: "Target 10")
        ]

        let example = PageLevel(
            sceneImageName: "sample_scene_art", // replace with your real art asset
            sceneImageSize: sceneSize,
            targets: targets
        )

        selectedLevel = example
        openPage = true
    }
}
