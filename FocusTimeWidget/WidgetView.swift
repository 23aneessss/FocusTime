import AppKit
import SwiftUI
import WidgetKit

struct WidgetView: View {
    @Environment(\.widgetFamily) private var family

    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget
            default:
                mediumWidget
            }
        }
        .containerBackground(for: .widget) {
            WidgetBackdropView(snapshot: entry.snapshot, family: family)
        }
    }

    private var mediumWidget: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FocusTime")
                        .font(FocusTypography.phase(size: 18))
                        .foregroundStyle(FocusPalette.textPrimary)

                    Text(entry.snapshot.phase.title)
                        .font(FocusTypography.phase(size: 16))
                        .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))
                }

                Spacer(minLength: 0)

                Text("Today")
                    .font(FocusTypography.phase(size: 13))
                    .foregroundStyle(FocusPalette.textPrimary.opacity(0.92))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 16)

            HStack(spacing: 22) {
                PixelRingView(
                    progress: entry.snapshot.ringProgress,
                    phase: entry.snapshot.phase,
                    segments: 36,
                    segmentLength: 10,
                    segmentThickness: 4
                )
                .frame(width: 90, height: 90)

                VStack(alignment: .leading, spacing: 14) {
                    statRow(label: "Focus", value: FocusFormatters.shortDurationString(from: entry.snapshot.todaySeconds))
                    statRow(label: "Sessions", value: "\(entry.snapshot.todaySessions)")
                    statRow(label: "Streak", value: "\(entry.snapshot.streak)")
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FocusTime")
                .font(FocusTypography.phase(size: 14))
                .foregroundStyle(FocusPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Text(entry.snapshot.phase.title)
                .font(FocusTypography.phase(size: 15))
                .foregroundStyle(FocusPalette.accent(for: entry.snapshot.phase))

            Spacer(minLength: 0)

            PixelRingView(
                progress: entry.snapshot.ringProgress,
                phase: entry.snapshot.phase,
                segments: 34,
                segmentLength: 9,
                segmentThickness: 4
            )
            .frame(width: 96, height: 96)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(FocusTypography.phase(size: 15))
                .foregroundStyle(FocusPalette.textPrimary.opacity(0.82))

            Spacer(minLength: 12)

            Text(value)
                .font(FocusTypography.phase(size: 16))
                .foregroundStyle(FocusPalette.textPrimary)
        }
    }
}

private struct WidgetBackdropView: View {
    let snapshot: FocusWidgetSnapshot
    let family: WidgetFamily

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(FocusPalette.widgetBackground)

                if family == .systemMedium, let image = NSImage(named: NSImage.Name(backgroundAssetName)) {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.none)
                        .antialiased(false)
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.black.opacity(0.22))
                        )
                } else {
                    fallbackBackground(proxy: proxy)
                }

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
        }
    }

    private var backgroundAssetName: String {
        switch snapshot.backgroundStyle {
        case .blueSkies:
            return "WidgetBackgroundBlueSkies"
        case .peachSunset:
            return "WidgetBackgroundPeachSunset"
        case .candyClouds:
            return "WidgetBackgroundCandyClouds"
        case .moonNight:
            return "WidgetBackgroundMoonNight"
        }
    }

    @ViewBuilder
    private func fallbackBackground(proxy: GeometryProxy) -> some View {
        let gradientColors = FocusPalette.skyGradient(
            for: snapshot.capturedAt,
            phase: snapshot.phase,
            style: snapshot.backgroundStyle
        )

        ZStack {
            LinearGradient(
                colors: [gradientColors[0].opacity(0.58), gradientColors[1].opacity(0.46), gradientColors[2].opacity(0.18)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Rectangle()
                .fill(FocusPalette.accent(for: snapshot.phase).opacity(family == .systemMedium ? 0.22 : 0.14))
                .frame(width: proxy.size.width * 0.55, height: family == .systemMedium ? 22 : 14)
                .rotationEffect(.degrees(-24))
                .offset(x: proxy.size.width * 0.18, y: -proxy.size.height * 0.28)

            Rectangle()
                .fill(Color.white.opacity(family == .systemMedium ? 0.09 : 0.05))
                .frame(width: proxy.size.width * 0.42, height: family == .systemMedium ? 14 : 10)
                .rotationEffect(.degrees(-24))
                .offset(x: -proxy.size.width * 0.18, y: proxy.size.height * 0.26)

            pixelBand(offsetX: family == .systemMedium ? -95 : -40, offsetY: family == .systemMedium ? -12 : -4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            pixelBand(offsetX: family == .systemMedium ? 120 : 60, offsetY: family == .systemMedium ? 18 : 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    private func pixelBand(offsetX: CGFloat, offsetY: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.08 : 0.04))
                    .frame(width: family == .systemMedium ? 16 : 12, height: family == .systemMedium ? 8 : 6)
            }
        }
        .offset(x: offsetX, y: offsetY)
    }
}
