import SwiftUI

// MARK: - Models

/// One tappable target in the scene.
struct PageTarget: Identifiable, Hashable {
    let id = UUID()
    let imageName: String            // bottom-right thumbnail
    let hitRect: CGRect              // in ORIGINAL scene pixels
    let accessibilityLabel: String
}

/// A level definition for one scene.
struct PageLevel: Hashable {
    let sceneImageName: String
    let sceneImageSize: CGSize       // ORIGINAL pixel size of the art
    let targets: [PageTarget]        // ordered search list
}

/// Helper that maps taps in the view to the original image pixel space,
/// accounting for how the image is fit into the view.
struct ImageSpaceMapper {
    let original: CGSize

    func fittedImageRect(in container: CGSize) -> CGRect {
        let imgA = original.width / original.height
        let viewA = container.width / container.height
        if imgA > viewA {
            // Image wider than view: height fits
            let scale = container.height / original.height
            let width = original.width * scale
            let x = (container.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: container.height)
        } else {
            // Image taller than view: width fits
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
    var onExit: (() -> Void)? = nil

    @State private var foundCount = 0
    @State private var currentIndex = 0
    @State private var showWin = false

    // tap feedback
    @State private var tapFeedback = false            // pulse on thumbnail
    @State private var hitBadgePoint: CGPoint? = nil  // checkmark where tapped

    // Stars are dynamic: equal to number of targets in this level
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
                        SlideToBackButton {
                            onExit?()
                        }
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
                        Image(target.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange.opacity(0.95))
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

                // WIN overlay
                if showWin {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48, weight: .bold))
                        Text("Great job!")
                            .font(.system(size: 44, weight: .heavy))
                        Text("You found them all!")
                            .font(.headline)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .shadow(radius: 8, y: 4)
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

    private func handleTap(at viewPoint: CGPoint, in container: CGSize) {
        guard let target = currentTarget else { return }
        let mapper = ImageSpaceMapper(original: level.sceneImageSize)
        guard let imgPt = mapper.viewPointToImagePoint(viewPoint, container: container) else { return }

        if target.hitRect.contains(imgPt) {
            // success!
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.25)) { tapFeedback = true }
            hitBadgePoint = viewPoint
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { tapFeedback = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.25)) { hitBadgePoint = nil }
            }

            foundCount = min(foundCount + 1, totalStars)

            // advance to next target (one active at a time)
            if currentIndex < level.targets.count - 1 {
                currentIndex += 1
            }

            // win when all targets found
            if foundCount >= totalStars {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showWin = true
                }
            }
        } else {
            // gentle miss feedback
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

