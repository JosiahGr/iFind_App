import SwiftUI

struct DashboardView: View {
    @State private var showBookshelf = false

    // Overlay routing
    private enum OverlayRoute { case auth, settings }
    @State private var overlayRoute: OverlayRoute? = nil

    var body: some View {
        if showBookshelf {
            BookshelfView(onBack: { showBookshelf = false })
                .ignoresSafeArea()
                .transaction { $0.animation = nil }
        } else {
            ZStack {
                // Background
                Image("dashboardView_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Bookshelf card
                DashboardCard(
                    title: "Bookshelf",
                    imageName: "bookshelfView_container"
                )
                .onTapGesture { withAnimation(.none) { showBookshelf = true } }

                // Settings button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            overlayRoute = .auth   // start at parent gate
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }

                // === Custom modal overlay ===
                if let route = overlayRoute {
                    ZStack {
                        // Dim behind the card
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture { overlayRoute = nil }

                        // Routed card
                        Group {
                            switch route {
                            case .auth:
                                ParentAuthView(
                                    onSuccess: { overlayRoute = .settings },
                                    onCancel:  { overlayRoute = nil },
                                    dimOpacity: 0 // card provides no extra dim
                                )
                            case .settings:
                                SettingsView(
                                    didClose: { overlayRoute = nil },
                                    onResetProgress: { /* show ResetProgressView */ },
                                    onRestorePurchases: { /* StoreKit restore */ },
                                    dimOpacity: 0 // card provides no extra dim
                                )
                            }
                        }
                        .transition(.opacity) // gentle fade between auth <-> settings
                    }
                    .animation(.easeInOut(duration: 0.2), value: overlayRoute)
                }
            }
        }
    }
}

// Same DashboardCard as before...
private struct DashboardCard: View {
    let title: String
    let imageName: String

    private let cardSize = CGSize(width: 336, height: 208)
    private let cornerRadius: CGFloat = 18
    private let frameBorderWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: cardSize.width, height: cardSize.height)
                .clipped()
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.white, lineWidth: frameBorderWidth)
                )
                .shadow(radius: 8, x: 2, y: 4)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
