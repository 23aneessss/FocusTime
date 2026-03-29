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

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let radius = side * 0.5 - segmentLength * 0.78
            let innerPadding = segmentLength + 13
            let ornamentOffset = (side * 0.5) - innerPadding - 8

            ZStack {
                ForEach(0..<segments, id: \.self) { index in
                    let isActive = index < activeSegments
                    let segmentAngle = (Double(index) / Double(segments)) * 360

                    ZStack {
                        Rectangle()
                            .fill(isActive ? FocusPalette.ringShadow(for: phase) : FocusPalette.ringShadow(for: phase).opacity(0.18))
                            .frame(width: segmentThickness, height: segmentLength)
                            .offset(y: -radius + 2)

                        Rectangle()
                            .fill(isActive ? FocusPalette.ringActive(for: phase) : FocusPalette.ringInactive(for: phase))
                            .frame(width: segmentThickness, height: segmentLength - 2)
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(isActive ? FocusPalette.ringHighlight(for: phase) : FocusPalette.ringHighlight(for: phase).opacity(0.16))
                                    .frame(height: 2)
                            }
                            .offset(y: -radius)
                    }
                    .rotationEffect(.degrees(segmentAngle))
                }

                Circle()
                    .fill(FocusPalette.centerFill(for: phase))
                    .padding(innerPadding)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [FocusPalette.centerInnerGlow, Color.white.opacity(0.04)],
                            center: .center,
                            startRadius: 8,
                            endRadius: side * 0.32
                        )
                    )
                    .padding(innerPadding + 1)

                Circle()
                    .strokeBorder(FocusPalette.panelStroke.opacity(0.7), lineWidth: 1)
                    .padding(innerPadding)

                Circle()
                    .strokeBorder(FocusPalette.accent(for: phase).opacity(0.18), lineWidth: 3)
                    .padding(innerPadding + 6)

                ForEach([
                    CGPoint(x: -ornamentOffset, y: -ornamentOffset),
                    CGPoint(x: ornamentOffset, y: -ornamentOffset),
                    CGPoint(x: -ornamentOffset, y: ornamentOffset),
                    CGPoint(x: ornamentOffset, y: ornamentOffset)
                ], id: \.self) { point in
                    Rectangle()
                        .fill(FocusPalette.accent(for: phase).opacity(0.42))
                        .frame(width: 7, height: 7)
                        .offset(x: point.x, y: point.y)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
