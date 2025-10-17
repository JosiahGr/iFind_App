import SwiftUI

struct PurchaseView: View {
    // Inject handlers when you wire up StoreKit
    var onBuy: (() -> Void)? = nil
    var onRestore: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background art
                Image("purchase_view_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Content
                VStack(spacing: 16) {
                    Text("UNLOCK ALL INTERACTIVE BOOKS")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.black.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    // Decorative container art
                    Image("purchase_screen_container")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(500, geo.size.width * 0.6),
                               height: min(180, geo.size.height * 0.35))
                        .accessibilityHidden(true)

                    // Buy button
                    Button {
                        onBuy?()
                    } label: {
                        Text("Unlock everything for $2.99")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .accessibilityLabel("Unlock everything for two dollars and ninety nine cents")

                    // Restore
                    Button {
                        onRestore?()
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .tint(.orange)
                    .padding(.horizontal, 24)

                    // Legal links
                    HStack(spacing: 6) {
                        Link("Terms of Service", destination: URL(string: "https://www.google.com")!)
                            .font(.subheadline)
                            .underline()
                        Text("and")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Link("Privacy Policy", destination: URL(string: "https://www.google.com")!)
                            .font(.subheadline)
                            .underline()
                    }
                    .foregroundStyle(.black)
                    .padding(.top, 2)
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            // Top-right close (since you hide the default back on Dashboard)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.gray.opacity(0.7))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Preview
#Preview("PurchaseView — Landscape", traits: .landscapeLeft) {
    NavigationStack {
        PurchaseView()
    }
}
