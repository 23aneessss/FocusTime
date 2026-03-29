import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: FocusTimerViewModel
    private let settingsInset: CGFloat = 12

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FocusWindowMetrics.panelCornerRadius, style: .continuous)
                .fill(FocusPalette.chrome)
                .shadow(color: FocusPalette.cardShadow, radius: 18, x: 0, y: 14)

            PixelBackgroundView(
                phase: viewModel.phase,
                reduceMotion: viewModel.settings.reduceMotion,
                style: viewModel.settings.backgroundStyle
            )
            .padding(8)

            TimerView(viewModel: viewModel)
        }
        .frame(width: FocusWindowMetrics.defaultWidth, height: FocusWindowMetrics.defaultHeight)
        .overlay(alignment: .topTrailing) {
            SettingsLink {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(FocusPalette.textPrimary)
                    .padding(9)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.black.opacity(0.26))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(FocusPalette.chromeBorder.opacity(0.55), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Open settings")
            .buttonStyle(.plain)
            .padding(.top, settingsInset)
            .padding(.trailing, settingsInset)
        }
        .background(
            WindowAccessor { window in
                AppDelegate.shared?.registerMainWindow(window)
            }
        )
    }
}
