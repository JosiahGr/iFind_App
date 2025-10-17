// BookView.swift
import SwiftUI

struct BookView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private enum OverlayRoute { case auth, purchase }
    @State private var overlayRoute: OverlayRoute? = nil

    var body: some View {
        ZStack {
            Image("animals_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 36) {
                    PageContainer(
                        title: "Page 1",
                        imageName: "animals_container",
                        status: PageStatus.available,
                        onOpen: { print("Open Page 1") },
                        onLocked: nil as (() -> Void)?
                    )

                    PageContainer(
                        title: "Page 2",
                        imageName: "animals_container",
                        status: PageStatus.completed,
                        onOpen: { print("Open Page 2 (Completed)") },
                        onLocked: nil as (() -> Void)?
                    )

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

            // Slide to Back (top left)
            VStack {
                HStack {
                    SlideToBackButton {
                        if let onBack { onBack() } else { dismiss() }
                    }
                    .padding(.leading, 24)
                    .padding(.top, 16)
                    .zIndex(2)
                    .opacity(overlayRoute == nil ? 1 : 0)
                    .allowsHitTesting(overlayRoute == nil)
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
