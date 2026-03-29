import SwiftUI

struct PixelRingView: View {
    var progress: Double
    var phase: TimerPhase
    var segments: Int = 48
    var segmentLength: CGFloat = 16
    var segmentThickness: CGFloat = 7

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

            ZStack {
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
}
