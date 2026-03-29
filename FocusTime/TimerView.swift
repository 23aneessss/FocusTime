import AppKit
import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        VStack(spacing: 22) {
            timerCluster
            controlsDeck
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var timerCluster: some View {
        ZStack {
            PixelRingView(
                progress: viewModel.progress,
                phase: viewModel.phase,
                segments: 42,
                segmentLength: 16,
                segmentThickness: 8
            )
            .frame(width: 190, height: 190)

            VStack(spacing: 8) {
                Text(viewModel.phase.title.uppercased())
                    .font(FocusTypography.pixel(size: 13))
                    .foregroundStyle(FocusPalette.accent(for: viewModel.phase))
                    .tracking(2.2)

                Text(viewModel.timeLabel)
                    .font(FocusTypography.timer(size: 29))
                    .monospacedDigit()
                    .tracking(1.1)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(FocusPalette.timerText)
                    .shadow(color: Color.black.opacity(0.38), radius: 0, x: 2, y: 2)
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(viewModel.timerAccessibilityValue)
            }
        }
        .frame(width: 190, height: 190)
    }

    private var controlsDeck: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: viewModel.resetTimer) {
                    PixelAssetButtonLabel(
                        assetNames: breakAwareAssetNames(base: "ButtonRestart"),
                        fallbackTitle: "Restart",
                        kind: .secondary,
                        phase: viewModel.phase,
                        width: 42,
                        height: 42
                    )
                }
                .accessibilityLabel("Restart timer")
                .buttonStyle(.plain)

                Button(action: viewModel.toggleTimer) {
                    PixelAssetButtonLabel(
                        assetNames: primaryActionAssetNames,
                        fallbackTitle: viewModel.primaryActionLabel,
                        kind: .primary,
                        phase: viewModel.phase,
                        width: 144,
                        height: 42
                    )
                }
                .accessibilityLabel(viewModel.primaryActionLabel)
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Button(action: viewModel.skipPhase) {
                PixelAssetButtonLabel(
                    assetNames: breakAwareAssetNames(base: "ButtonSkip"),
                    fallbackTitle: "Skip",
                    kind: .secondary,
                    phase: viewModel.phase,
                    width: 100,
                    height: 38
                )
            }
            .accessibilityLabel("Skip to next phase")
            .buttonStyle(.plain)
        }
        .frame(width: 202)
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
