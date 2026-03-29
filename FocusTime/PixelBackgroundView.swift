import AppKit
import SwiftUI

struct PixelBackgroundView: View {
    var phase: TimerPhase
    var reduceMotion: Bool
    var style: FocusBackgroundStyle

    private var contentCornerRadius: CGFloat {
        FocusWindowMetrics.panelCornerRadius
    }

    private var assetBackdropColor: Color {
        FocusPalette.skyGradient(for: .now, phase: phase, style: style).first ?? FocusPalette.chrome
    }

    var body: some View {
        if let image = NSImage(named: NSImage.Name(style.assetName)) {
            ZStack {
                Rectangle()
                    .fill(assetBackdropColor)

                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: contentCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: contentCornerRadius, style: .continuous)
                    .fill(phase == .break ? Color.black.opacity(0.10) : Color.white.opacity(0.02))
            )
        } else {
            Group {
                if reduceMotion {
                    timelineBody(schedule: .periodic(from: .now, by: 60))
                } else {
                    timelineBody(schedule: .animation(minimumInterval: 1 / 12, paused: false))
                }
            }
        }
    }

    private func timelineBody<S: TimelineSchedule>(schedule: S) -> some View {
        TimelineView(schedule) { context in
            Canvas { canvas, size in
                let gradient = Gradient(colors: FocusPalette.skyGradient(for: context.date, phase: phase, style: style))
                canvas.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        gradient,
                        startPoint: .zero,
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )

                drawSunOrMoon(on: canvas, size: size, date: context.date)
                drawCloudLayer(on: canvas, size: size, date: context.date, yBase: size.height * 0.24, scale: 0.96, opacity: 0.82)
                drawCloudLayer(on: canvas, size: size, date: context.date, yBase: size.height * 0.66, scale: 1.16, opacity: 0.98)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: contentCornerRadius, style: .continuous))
    }

    private func drawSunOrMoon(on canvas: GraphicsContext, size: CGSize, date: Date) {
        let colors = FocusPalette.skyGradient(for: date, phase: phase, style: style)
        let isNight = phase == .break || style == .moonNight
        let bodyRect = CGRect(x: size.width * 0.72, y: size.height * 0.10, width: size.width * 0.10, height: size.width * 0.10)

        if isNight {
            canvas.fill(Path(ellipseIn: bodyRect), with: .color(.white.opacity(0.95)))
            canvas.fill(
                Path(ellipseIn: bodyRect.offsetBy(dx: size.width * 0.022, dy: 0)),
                with: .color(colors[0].opacity(0.86))
            )

            for offset in stride(from: 0.16, through: 0.84, by: 0.14) {
                let starRect = CGRect(x: size.width * offset, y: size.height * 0.18, width: 4, height: 4)
                canvas.fill(Path(starRect), with: .color(.white.opacity(0.84)))
            }
        } else {
            canvas.fill(Path(ellipseIn: bodyRect), with: .color(.white.opacity(0.95)))
            canvas.fill(Path(ellipseIn: bodyRect.insetBy(dx: -12, dy: -12)), with: .color(.white.opacity(0.10)))
        }
    }

    private func drawCloudLayer(
        on canvas: GraphicsContext,
        size: CGSize,
        date: Date,
        yBase: CGFloat,
        scale: CGFloat,
        opacity: CGFloat
    ) {
        let drift = reduceMotion ? 0 : CGFloat(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 36)) * 2
        let cloudColor = FocusPalette.cloudFill(for: style, phase: phase)
        let shadowColor = FocusPalette.cloudShadow(for: style, phase: phase)
        let block = max(4, size.width / 54) * scale

        let patterns: [[CGPoint]] = [
            [.init(x: 0, y: 2), .init(x: 1, y: 1), .init(x: 2, y: 1), .init(x: 3, y: 2), .init(x: 1, y: 0), .init(x: 2, y: 0)],
            [.init(x: 0, y: 2), .init(x: 1, y: 2), .init(x: 2, y: 1), .init(x: 3, y: 1), .init(x: 4, y: 2), .init(x: 2, y: 0), .init(x: 3, y: 0)],
            [.init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 2, y: 0), .init(x: 3, y: 1), .init(x: 1, y: 0)]
        ]

        for index in 0..<patterns.count {
            let pattern = patterns[index]
            let baseX = ((CGFloat(index) * size.width * 0.34) - drift).truncatingRemainder(dividingBy: size.width * 1.1)
            let wrappedX = baseX < -size.width * 0.18 ? baseX + size.width * 1.1 : baseX

            for point in pattern {
                let rect = CGRect(
                    x: wrappedX + (point.x * block * 1.8),
                    y: yBase + (point.y * block * 1.25),
                    width: block * 1.7,
                    height: block * 1.25
                )

                canvas.fill(Path(rect.offsetBy(dx: 0, dy: block * 0.45)), with: .color(shadowColor.opacity(opacity)))
                canvas.fill(Path(rect), with: .color(cloudColor.opacity(opacity)))
            }
        }
    }
}
