import AppKit
import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            timerCluster

            Spacer(minLength: 16)

            controlsDeck
                .padding(.bottom, 14)
        }
        .padding(.horizontal, 18)
    }

    private var timerCluster: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.20))
                .frame(width: 228, height: 228)
                .blur(radius: 18)

            PixelRingView(
                progress: viewModel.progress,
                phase: viewModel.phase,
                segments: 42,
                segmentLength: 17,
                segmentThickness: 8
            )
            .frame(width: 214, height: 214)

            VStack(spacing: 10) {
                Text(viewModel.phase.title.uppercased())
                    .font(FocusTypography.pixel(size: 15))
                    .foregroundStyle(FocusPalette.accent(for: viewModel.phase))
                    .tracking(2.8)

                Text(viewModel.timeLabel)
                    .font(FocusTypography.timer(size: 34))
                    .monospacedDigit()
                    .tracking(1.4)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(FocusPalette.timerText)
                    .shadow(color: Color.black.opacity(0.38), radius: 0, x: 2, y: 2)
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(viewModel.timerAccessibilityValue)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var controlsDeck: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                Button(action: viewModel.resetTimer) {
                    PixelAssetButtonLabel(
                        assetNames: breakAwareAssetNames(base: "ButtonRestart"),
                        fallbackTitle: "Restart",
                        kind: .secondary,
                        phase: viewModel.phase,
                        width: 48,
                        height: 48
                    )
                }
                .accessibilityLabel("Restart timer")
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Button(action: viewModel.skipPhase) {
                    PixelAssetButtonLabel(
                        assetNames: breakAwareAssetNames(base: "ButtonSkip"),
                        fallbackTitle: "Skip",
                        kind: .secondary,
                        phase: viewModel.phase,
                        width: 112,
                        height: 44
                    )
                }
                .accessibilityLabel("Skip to next phase")
                .buttonStyle(.plain)
            }
            .frame(maxWidth: 236)

            Button(action: viewModel.toggleTimer) {
                PixelAssetButtonLabel(
                    assetNames: primaryActionAssetNames,
                    fallbackTitle: viewModel.primaryActionLabel,
                    kind: .primary,
                    phase: viewModel.phase,
                    width: 182,
                    height: 54
                )
            }
            .accessibilityLabel(viewModel.primaryActionLabel)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.20))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FocusPalette.chromeBorder.opacity(0.38), lineWidth: 1)
        )
    }

    private var primaryActionAssetNames: [String] {
        let base = viewModel.isRunning ? "ButtonPause" : "ButtonStart"
        return breakAwareAssetNames(base: base)
    }

    private func breakAwareAssetNames(base: String) -> [String] {
        if viewModel.phase == .break {
            return ["\(base)Break", base]
        }

        return [base]
    }
}

private enum PixelButtonKind {
    case primary
    case secondary
}

private struct PixelAssetButtonLabel: View {
    let assetNames: [String]
    let fallbackTitle: String
    let kind: PixelButtonKind
    let phase: TimerPhase
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let resolvedAssetName = resolvedAssetName {
                Image(resolvedAssetName)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .scaledToFit()
                    .frame(width: width, height: height)
            } else {
                fallbackLabel
                    .frame(width: width, height: height)
            }
        }
        .contentShape(Rectangle())
        .scaleEffect(0.995)
    }

    private var resolvedAssetName: String? {
        assetNames.first { NSImage(named: NSImage.Name($0)) != nil }
    }

    private var fallbackLabel: some View {
        Text(fallbackTitle)
            .font(FocusTypography.pixel(size: kind == .primary ? 13 : 11))
            .foregroundStyle(kind == .primary ? Color.white : FocusPalette.chrome)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: kind == .primary ? 16 : 12, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: kind == .primary ? 16 : 12, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: kind == .primary ? 12 : 9, style: .continuous)
                    .stroke(highlightColor.opacity(0.75), lineWidth: 1)
                    .padding(3)
            )
    }

    private var backgroundColor: Color {
        switch kind {
        case .primary:
            return FocusPalette.accent(for: phase)
        case .secondary:
            return Color.white.opacity(0.92)
        }
    }

    private var borderColor: Color {
        switch kind {
        case .primary:
            return FocusPalette.accent(for: phase).opacity(0.7)
        case .secondary:
            return FocusPalette.panelStroke
        }
    }

    private var highlightColor: Color {
        switch kind {
        case .primary:
            return FocusPalette.ringHighlight(for: phase)
        case .secondary:
            return Color.white
        }
    }
}
