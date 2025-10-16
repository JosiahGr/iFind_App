import SwiftUI

struct BookView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    // Optional overlay routing (ParentAuth -> Purchase)
    private enum OverlayRoute { case auth, purchase }
    @State private var overlayRoute: OverlayRoute? = nil

    var body: some View {
        ZStack {
            Image("animals_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Horizontal row of pages
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 36) {

                    // 1) Available page
                    PageContainer(
                        title: "Page 1",
                        imageName: "animals_container",
                        status: PageStatus.available,
                        onOpen: {
                            // TODO: push your real PageView
                            print("Open Page 1")
                        },
                        onLocked: nil as (() -> Void)?
                    )

                    // 2) Completed page
                    PageContainer(
                        title: "Page 2",
                        imageName: "animals_container",
                        status: PageStatus.completed,
                        onOpen: {
                            print("Open Page 2 (Completed)")
                        },
                        onLocked: nil as (() -> Void)?
                    )

                    // 3) Locked page (ParentAuth -> Purchase)
                    PageContainer(
                        title: "New Pack",
                        imageName: "animals_container",
                        status: PageStatus.locked,
                        onOpen: nil,
                        onLocked: { overlayRoute = .auth }
                    )
                }
                .padding(.leading, 124)
                .padding(.trailing, 40)
                .padding(.top, 72)
                .padding(.bottom, 24)
            }

            // Simple back chevron (swap for slide-home if you want)
            VStack {
                HStack {
                    Button {
                        if let onBack { onBack() } else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundStyle(.black.opacity(0.85))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.leading, 24)
                    .padding(.top, 16)
                    Spacer()
                }
                Spacer()
            }

            // Overlay flow
            if let route = overlayRoute {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { overlayRoute = nil }

                    Group {
                        switch route {
                        case .auth:
                            ParentAuthView(
                                onSuccess: { overlayRoute = .purchase },
                                onCancel:  { overlayRoute = nil },
                                dimOpacity: 0
                            )
                        case .purchase:
                            PurchaseView(onClose: { overlayRoute = nil })
                                .frame(maxWidth: 520)
                                .background(
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
                                )
                                .padding()
                        }
                    }
                    .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.2), value: overlayRoute)
            }
        }
    }
}

#Preview("BookView – Landscape", traits: .landscapeLeft) {
    BookView()
}
