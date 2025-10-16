//
//  BookshelfView.swift
//  iFind_App
//
//  Created by Josiah Green on 10/16/25.
//

import SwiftUI

struct BookshelfView: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var openBook = false  // opens the unlocked book

    var body: some View {
        if openBook {
            // Placeholder BookView for now
            BookView()
                .ignoresSafeArea()
                .transaction { $0.animation = nil }
        } else {
            ZStack {
                // Background wallpaper (kept as in your version)
                Image("bookshelfView_container")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Horizontal scroll for book cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 36) {
                        // Unlocked book — Animals
                        BookshelfCard(
                            title: "Animals",
                            imageName: "animals_container",
                            isLocked: false
                        )
                        .onTapGesture {
                            withAnimation(.none) { openBook = true }
                        }

                        // Locked placeholders
                        BookshelfCard(
                            title: "Coming Soon",
                            imageName: "bookshelfView_wallpaper",
                            isLocked: true
                        )

                        BookshelfCard(
                            title: "Coming Soon",
                            imageName: "bookshelfView_wallpaper",
                            isLocked: true
                        )
                    }
                    // Your adjusted padding (unchanged)
                    .padding(.leading, 124)
                    .padding(.trailing, 40)
                    .padding(.top, 72)
                    .padding(.bottom, 24)
                }

                // Top-right: Slide-to-Home button (replaces back chevron)
                VStack {
                    HStack {
                        Spacer()
                        SlideToHomeButton {
                            goBack() // return to previous screen (Dashboard)
                        }
                        .frame(width: 180)
                        .padding(.trailing, 32)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
            }
        }
    }

    private func goBack() {
        if let onBack { onBack() } else { dismiss() }
    }
}

// MARK: - Card
private struct BookshelfCard: View {
    let title: String
    let imageName: String
    let isLocked: Bool

    private let size = CGSize(width: 280, height: 220)
    private let corner: CGFloat = 5
    private let borderWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
                .cornerRadius(corner)
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(.black, lineWidth: borderWidth)
                )
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                .clipShape(RoundedRectangle(cornerRadius: corner))
                .overlay(lockedOverlay)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.black)
                .shadow(radius: 2)
                .padding(.bottom, 10)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .contentShape(RoundedRectangle(cornerRadius: corner))
    }

    @ViewBuilder
    private var lockedOverlay: some View {
        if isLocked {
            RoundedRectangle(cornerRadius: corner)
                .fill(Color.black.opacity(0.35))

            HStack(spacing: 8) {
                Image(systemName: "lock.fill").font(.title2.bold())
                Text("Locked").font(.headline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(10)
            .background(.black.opacity(0.6), in: Capsule())
        } else {
            EmptyView()
        }
    }
}

// MARK: - Placeholder BookView
struct BookView: View {
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            Text("Book View (Placeholder)")
                .font(.largeTitle).bold()
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview
#Preview("BookshelfView – Landscape", traits: .landscapeLeft) {
    BookshelfView()
}
