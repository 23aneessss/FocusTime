import AppKit
import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                PixelRingView(
                    progress: viewModel.progress,
                    phase: viewModel.phase,
                    segments: 52,
                    segmentLength: 16,
                    segmentThickness: 7
                )
                .frame(width: 160, height: 160)

                VStack(spacing: 8) {
                    Text(viewModel.phase.title.uppercased())
                        .font(FocusTypography.phase(size: 11))
                        .foregroundStyle(FocusPalette.accent(for: viewModel.phase))
                        .tracking(2.2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.22))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(FocusPalette.accent(for: viewModel.phase).opacity(0.35), lineWidth: 1)
                        )

                    Text(viewModel.timeLabel)
                        .font(FocusTypography.pixel(size: 24))
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(FocusPalette.timerText)
                        .accessibilityLabel("Time remaining")
                        .accessibilityValue(viewModel.timerAccessibilityValue)
                }
            }
            .padding(.top, 30)

            Spacer(minLength: 14)

            HStack(spacing: 12) {
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

                Button(action: viewModel.skipPhase) {
                    PixelAssetButtonLabel(
                        assetNames: breakAwareAssetNames(base: "ButtonSkip"),
                        fallbackTitle: "Skip",
                        kind: .secondary,
                        phase: viewModel.phase,
                        width: 108,
                        height: 40
                    )
                }
                .accessibilityLabel("Skip to next phase")
                .buttonStyle(.plain)
            }

            Spacer(minLength: 10)

            Button(action: viewModel.toggleTimer) {
                PixelAssetButtonLabel(
                    assetNames: primaryActionAssetNames,
                    fallbackTitle: viewModel.primaryActionLabel,
                    kind: .primary,
                    phase: viewModel.phase,
                    width: 164,
                    height: 48
                )
            }
            .accessibilityLabel(viewModel.primaryActionLabel)
            .buttonStyle(.plain)
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 18)
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
            return FocusPalette.panelFill
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
