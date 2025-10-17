import SwiftUI

struct BookView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    // If you still need parent auth for *anything* inside BookView, keep this.
    // Otherwise you can delete OverlayRoute + overlay entirely.
    private enum OverlayRoute { case auth }
    @State private var overlayRoute: OverlayRoute? = nil

    @State private var pressedIndex: Int? = nil

    // Around 65% of the old size
    private let cardSize = CGSize(width: 160, height: 200)

    var body: some View {
        ZStack {
            Image("animals_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.0)

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
                        .pressToScale { pressing in pressedIndex = pressing ? i : nil }
                        .bobbing(
                            amplitude: 5,
                            period: 3.4,
                            phase: Double(i) * 0.2,
                            paused: overlayRoute != nil || pressedIndex == i
                        )
                        // Example: if you want auth when tapping a locked page:
                        // .onTapGesture {
                        //     if status == .locked { overlayRoute = .auth }
                        // }
                    }
                }
                .padding(.leading, 80)
                .padding(.trailing, 32)
                .padding(.top, 56)
                .padding(.bottom, 24)
            }

            // Back chevron
            VStack {
                HStack {
                    Button {
                        if let onBack { onBack() } else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundStyle(.black.opacity(0.85))
                            .padding(20)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .padding(.leading, 24)
                    .padding(.top, 20)
                    Spacer()
                }
                Spacer()
            }
            .zIndex(2)
            .opacity(overlayRoute == nil ? 1 : 0)
            .allowsHitTesting(overlayRoute == nil)

            // Optional: parent auth overlay ONLY (no purchase case)
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
    }
}
