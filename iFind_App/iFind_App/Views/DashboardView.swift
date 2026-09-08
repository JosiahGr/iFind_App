import SwiftUI

struct DashboardView: View {
    @State private var showBookshelf = false

    // Value-based navigation (Hashable + Codable)
    enum Route: String, Hashable, Codable { case purchase }
    @State private var navPath = NavigationPath()

    // Overlay routes
    private enum OverlayRoute { case authForSettings, authForPurchase, settings }
    @State private var overlayRoute: OverlayRoute? = nil

    var body: some View {
        if showBookshelf {
            BookshelfView(onBack: { showBookshelf = false })
                .ignoresSafeArea()
                .transaction { $0.animation = nil }
        } else {
            NavigationStack(path: $navPath) {
                ZStack {
                    Image("dashboardView_wallpaper")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    // Bookshelf card
                    DashboardCard(title: "Bookshelf", imageName: "bookshelfView_container")
                        .onTapGesture { withAnimation(.none) { showBookshelf = true } }

                    // Top-right buttons (purchase + settings)
                    VStack {
                        HStack(spacing: 8) {
                            Spacer()

                            // Purchase (auth first)
                            Button {
                                overlayRoute = .authForPurchase
                            } label: {
                                Image(systemName: "crown.fill") // or "star.fill"
                                    .font(.title2)
                                    .padding(16)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .accessibilityLabel("Open purchase screen")
                            }

                            // Settings
                            Button {
                                overlayRoute = .authForSettings
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .padding(16)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .accessibilityLabel("Open settings")
                            }
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 32)

                        Spacer()
                    }

                    // Overlays (auth/settings only)
                    if let route = overlayRoute {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture { overlayRoute = nil }

                            // if/else avoids ViewBuilder inference issues
                            if route == .authForSettings {
                                ParentAuthView(
                                    onSuccess: { overlayRoute = .settings },
                                    onCancel:  { overlayRoute = nil },
                                    dimOpacity: 0
                                )
                            } else if route == .authForPurchase {
                                ParentAuthView(
                                    onSuccess: {
                                        overlayRoute = nil
                                        // push next tick so it isn’t swallowed by fade-out
                                        DispatchQueue.main.async {
                                            navPath.append(Route.purchase) // <-- explicit type
                                        }
                                    },
                                    onCancel:  { overlayRoute = nil },
                                    dimOpacity: 0
                                )
                            } else if route == .settings {
                                SettingsView(
                                    didClose: { overlayRoute = nil },
                                    onResetProgress: { /* show ResetProgressView */ },
                                    onRestorePurchases: { /* StoreKit restore */ },
                                    dimOpacity: 0
                                )
                            }
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: overlayRoute)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .purchase:
                        PurchaseView()
                    }
                }
            }
        }
    }
}

// MARK: - DashboardCard (unchanged)
private struct DashboardCard: View {
    let title: String
    let imageName: String

    private let cardSize = CGSize(width: 315, height: 250)
    private let cornerRadius: CGFloat = 18
    private let frameBorderWidth: CGFloat = 18

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: cardSize.width, height: cardSize.height)
                .clipped()
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius + frameBorderWidth / 2)
                        .stroke(Color.white.opacity(0.8), lineWidth: frameBorderWidth)
                        .padding(-frameBorderWidth / 2)
                )
                .shadow(radius: 8, x: 2, y: 4)

            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
