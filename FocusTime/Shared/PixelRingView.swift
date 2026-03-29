import SwiftUI

struct PixelRingView: View {
    var progress: Double
    var phase: TimerPhase
    var segments: Int = 48
    var segmentLength: CGFloat = 16
    var segmentThickness: CGFloat = 7
    var showsOrbitDust: Bool = true

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var activeSegments: Int {
        Int((clampedProgress * Double(segments)).rounded(.down))
    }

    private var pixelSpacing: CGFloat {
        max(1, segmentThickness * 0.22)
    }

    private var pixelCount: Int {
        max(2, Int((segmentLength / max(segmentThickness, 1)).rounded(.toNearestOrAwayFromZero)))
    }

    private var renderedSegmentLength: CGFloat {
        (CGFloat(pixelCount) * segmentThickness) + (CGFloat(max(pixelCount - 1, 0)) * pixelSpacing)
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let radius = side * 0.5 - renderedSegmentLength * 0.80 - 7
            let innerPadding = renderedSegmentLength + 18

            ZStack {
                if showsOrbitDust {
                    orbitDustLayer(side: side)
                }

                ForEach(0..<segments, id: \.self) { index in
                    let isActive = index < activeSegments
                    let segmentAngle = (Double(index) / Double(segments)) * 360

                    VStack(spacing: pixelSpacing) {
                        ForEach(0..<pixelCount, id: \.self) { pixelIndex in
                            Rectangle()
                                .fill(segmentColor(for: pixelIndex, isActive: isActive))
                                .frame(width: segmentThickness, height: segmentThickness)
                        }
                    }
                    .offset(y: -radius)
                    .rotationEffect(.degrees(segmentAngle))
                }

                Circle()
                    .fill(FocusPalette.centerFill(for: phase))
                    .padding(innerPadding)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [FocusPalette.centerInnerGlow, FocusPalette.accent(for: phase).opacity(0.10)],
                            center: .center,
                            startRadius: 12,
                            endRadius: side * 0.34
                        )
                    )
                    .padding(innerPadding + 1)

                Circle()
                    .strokeBorder(Color.black.opacity(0.46), lineWidth: 8)
                    .padding(innerPadding - 6)

                Circle()
                    .strokeBorder(FocusPalette.panelStroke.opacity(0.7), lineWidth: 1)
                    .padding(innerPadding)

                Circle()
                    .strokeBorder(FocusPalette.accent(for: phase).opacity(0.26), lineWidth: 2)
                    .padding(innerPadding + 6)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func segmentColor(for pixelIndex: Int, isActive: Bool) -> Color {
        if isActive {
            let activeColors = [
                FocusPalette.ringHighlight(for: phase),
                FocusPalette.ringActive(for: phase),
                FocusPalette.ringShadow(for: phase)
            ]

            return activeColors[min(pixelIndex, activeColors.count - 1)]
        }

        let inactiveBase = FocusPalette.ringInactive(for: phase)
        let inactiveOpacity = [0.86, 0.62, 0.44]
        return inactiveBase.opacity(inactiveOpacity[min(pixelIndex, inactiveOpacity.count - 1)])
    }

    @ViewBuilder
    private func orbitDustLayer(side: CGFloat) -> some View {
        let pixels: [(x: CGFloat, y: CGFloat, size: CGFloat, colorIndex: Int)] = [
            (-0.68, -0.10, 8, 1),
            (-0.53, -0.42, 6, 2),
            (-0.31, 0.66, 8, 1),
            (0.00, -0.73, 7, 3),
            (0.18, 0.58, 6, 2),
            (0.42, -0.56, 8, 1),
            (0.64, -0.14, 6, 0),
            (0.58, 0.34, 7, 3),
            (-0.47, 0.33, 7, 2),
            (0.02, 0.78, 8, 1)
        ]
        let palette = FocusPalette.sparklePalette(for: phase)

        ForEach(Array(pixels.enumerated()), id: \.offset) { _, pixel in
            Rectangle()
                .fill(palette[pixel.colorIndex % palette.count])
                .frame(width: pixel.size, height: pixel.size)
                .offset(x: pixel.x * side * 0.46, y: pixel.y * side * 0.46)
        }
    }
}
