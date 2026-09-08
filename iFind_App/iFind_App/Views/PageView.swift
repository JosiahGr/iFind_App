import SwiftUI
import UIKit

// MARK: - Models

struct PageTarget: Identifiable, Hashable {
    let id = UUID()
    let imageName: String             // preferred thumbnail asset; fallback is auto-crop
    let hitRect: CGRect               // ORIGINAL scene pixels
    let accessibilityLabel: String
    var thumbnailInsetFraction: CGFloat = 0.12
}

struct PageLevel: Hashable {
    let sceneImageName: String
    let sceneImageSize: CGSize        // ORIGINAL scene pixels
    let targets: [PageTarget]         // ordered search list
}

struct ImageSpaceMapper {
    let original: CGSize

    func fittedImageRect(in container: CGSize) -> CGRect {
        let imgA = original.width / original.height
        let viewA = container.width / container.height
        if imgA > viewA {
            let scale = container.height / original.height
            let width = original.width * scale
            let x = (container.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: container.height)
        } else {
            let scale = container.width / original.width
            let height = original.height * scale
            let y = (container.height - height) / 2
            return CGRect(x: 0, y: y, width: container.width, height: height)
        }
    }

    func viewPointToImagePoint(_ p: CGPoint, container: CGSize) -> CGPoint? {
        let fitted = fittedImageRect(in: container)
        guard fitted.contains(p) else { return nil }
        let sx = original.width / fitted.width
        let sy = original.height / fitted.height
        return CGPoint(x: (p.x - fitted.minX) * sx,
                       y: (p.y - fitted.minY) * sy)
    }
}

// MARK: - PageView

struct PageView: View {
    let level: PageLevel
    var onExit: (() -> Void)? = nil           // close / pop
    var onContinue: (() -> Void)? = nil       // optional: push next level

    @State private var foundCount = 0
    @State private var currentIndex = 0
    @State private var showWin = false

    // tap feedback
    @State private var tapFeedback = false
    @State private var hitBadgePoint: CGPoint? = nil

    private var totalStars: Int { max(1, level.targets.count) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // SCENE
                Image(level.sceneImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { g in
                                handleTap(at: g.location, in: geo.size)
                            }
                    )

                // CHECKMARK where correct tap happened
                if let p = hitBadgePoint {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 36, weight: .bold))
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .position(p)
                        .transition(.scale.combined(with: .opacity))
                }

                // UI overlay
                VStack {
                    HStack {
                        // top-left back slider
                        SlideToBackButton { onExit?() }
                            .padding(.leading, 24)
                            .padding(.top, 16)

                        Spacer()

                        // top-right stars
                        StarMeter(found: foundCount, total: totalStars)
                            .padding(.trailing, 24)
                            .padding(.top, 16)
                    }

                    Spacer()

                    // bottom-right current target thumbnail
                    if let target = currentTarget {
                        thumbnailView(for: target)
                            .frame(width: 104, height: 104)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                            )
                            .padding(.trailing, 24)
                            .padding(.bottom, 18)
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .strokeBorder(Color.white.opacity(tapFeedback ? 0.9 : 0.0), lineWidth: 3)
                                    .frame(width: 22, height: 22)
                                    .padding(6)
                                    .opacity(tapFeedback ? 1 : 0)
                                    .animation(.easeOut(duration: 0.35), value: tapFeedback)
                            }
                            .accessibilityLabel(Text(target.accessibilityLabel))
                            .accessibilityHint("Find this in the picture")
                            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    }
                }
                .ignoresSafeArea()

                // WIN overlay — with Restart & Continue
                if showWin {
                    VStack(spacing: 18) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 52, weight: .bold))
                            .symbolRenderingMode(.hierarchical)

                        Text("Great job!")
                            .font(.system(size: 44, weight: .heavy))

                        Text("You found them all!")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 20) {
                            // Restart
                            Button {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                    restartGame()
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 48, weight: .bold))
                                    Text("Restart")
                                        .font(.headline)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                            }

                            // Continue / Next
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.easeIn(duration: 0.15)) {
                                    showWin = false
                                }
                                // If dev provided a handler, use it; else default to exit
                                (onContinue ?? onExit)?()
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 48, weight: .bold))
                                    Text("Continue")
                                        .font(.headline)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                            }
                        }
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.white, Color.orange) // inner/icon, outer circle
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .statusBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    private var currentTarget: PageTarget? {
        guard !level.targets.isEmpty else { return nil }
        return level.targets[min(currentIndex, level.targets.count - 1)]
    }

    private func restartGame() {
        foundCount = 0
        currentIndex = 0
        showWin = false
    }

    private func handleTap(at viewPoint: CGPoint, in container: CGSize) {
        guard let target = currentTarget else { return }
        let mapper = ImageSpaceMapper(original: level.sceneImageSize)
        guard let imgPt = mapper.viewPointToImagePoint(viewPoint, container: container) else { return }

        if target.hitRect.contains(imgPt) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.25)) { tapFeedback = true }
            hitBadgePoint = viewPoint
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { tapFeedback = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.25)) { hitBadgePoint = nil }
            }

            foundCount = min(foundCount + 1, totalStars)

            if currentIndex < level.targets.count - 1 {
                currentIndex += 1
            }

            if foundCount >= totalStars {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showWin = true
                }
            }
        } else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.3)
        }
    }
}

// MARK: - Star Meter
private struct StarMeter: View {
    let found: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Image(systemName: i < found ? "star.fill" : "star")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(i < found ? Color.orange : Color.orange.opacity(0.5))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Thumbnails (asset preferred, auto-crop fallback)

extension PageView {
    @ViewBuilder
    func thumbnailView(for target: PageTarget) -> some View {
        if let ui = UIImage(named: target.imageName) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
        } else if let cropped = croppedThumbnail(for: target) {
            Image(uiImage: cropped)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
        }
    }

    private func croppedThumbnail(for target: PageTarget) -> UIImage? {
        guard let scene = UIImage(named: level.sceneImageName)?.cgImage else { return nil }

        let insetX = target.hitRect.width  * target.thumbnailInsetFraction
        let insetY = target.hitRect.height * target.thumbnailInsetFraction
        var crop = target.hitRect.insetBy(dx: -insetX, dy: -insetY)

        // Clamp to image bounds
        crop.origin.x = max(0, crop.origin.x)
        crop.origin.y = max(0, crop.origin.y)
        crop.size.width  = min(crop.size.width,  CGFloat(scene.width)  - crop.origin.x)
        crop.size.height = min(crop.size.height, CGFloat(scene.height) - crop.origin.y)

        // Integer pixel rect for CGImage cropping
        let pixelRect = CGRect(
            x: floor(crop.origin.x),
            y: floor(crop.origin.y),
            width: floor(crop.size.width),
            height: floor(crop.size.height)
        )

        guard let sub = scene.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: sub, scale: UIScreen.main.scale, orientation: .up)
    }
}
