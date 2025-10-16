import SwiftUI

struct PurchaseView: View {
    var onClose: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose?() }

            // Card
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        onClose?()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.circle.fill)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                }
                .padding(.trailing, 8)

                Text("Purchase This Book")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("Unlock all pages and continue discovering!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer().frame(height: 12)

                Button {
                    print("Simulate purchase complete")
                    onClose?()
                } label: {
                    Text("Purchase for $0.99")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }

                Spacer().frame(height: 8)

                Text("This is a placeholder purchase screen.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: 420)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
            )
            .padding()
        }
    }
}

#Preview("PurchaseView – Modal") {
    PurchaseView()
        .previewInterfaceOrientation(.landscapeLeft)
}
//
//  PurchaseView.swift
//  iFind_App
//
//  Created by Josiah Green on 10/16/25.
//

