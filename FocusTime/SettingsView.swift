import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FocusTimerViewModel

    var body: some View {
        Form {
            Section("Durations") {
                Stepper(value: focusMinutesBinding, in: 5...90, step: 5) {
                    settingRow(title: "Focus length", value: "\(viewModel.settings.focusMinutes) min")
                }

                Stepper(value: breakMinutesBinding, in: 1...30, step: 1) {
                    settingRow(title: "Break length", value: "\(viewModel.settings.breakMinutes) min")
                }
            }

            Section("Experience") {
                Toggle("Play sound at session end", isOn: soundBinding)
                Toggle("Reduce background motion", isOn: reduceMotionBinding)

                Picker("Window corner", selection: cornerBinding) {
                    ForEach(FocusCorner.allCases) { corner in
                        Text(corner.displayName).tag(corner)
                    }
                }
            }

            Section("Appearance") {
                Picker("Background", selection: backgroundBinding) {
                    ForEach(FocusBackgroundStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }

                Text("You can keep these built-in pixel backgrounds, or later add asset-catalog images with matching names and reuse this picker.")
                    .font(FocusTypography.body(size: 11))
                    .foregroundStyle(FocusPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Section("Notes") {
                Text("FocusTime stays visible in the Dock for this first version. If you later want agent-style behavior with no Dock icon, add LSUIElement deliberately after the main workflow is stable.")
                    .font(FocusTypography.body(size: 12))
                    .foregroundStyle(FocusPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .padding(18)
        .frame(minWidth: 430, minHeight: 320)
    }

    private var focusMinutesBinding: Binding<Int> {
        Binding(
            get: { viewModel.settings.focusMinutes },
            set: { viewModel.updateFocusDuration(minutes: $0) }
        )
    }

    private var breakMinutesBinding: Binding<Int> {
        Binding(
            get: { viewModel.settings.breakMinutes },
            set: { viewModel.updateBreakDuration(minutes: $0) }
        )
    }

    private var soundBinding: Binding<Bool> {
        Binding(
            get: { viewModel.settings.soundEnabled },
            set: { viewModel.updateSoundEnabled($0) }
        )
    }

    private var reduceMotionBinding: Binding<Bool> {
        Binding(
            get: { viewModel.settings.reduceMotion },
            set: { viewModel.updateReduceMotion($0) }
        )
    }

    private var cornerBinding: Binding<FocusCorner> {
        Binding(
            get: { viewModel.settings.preferredCorner },
            set: { viewModel.updatePreferredCorner($0) }
        )
    }

    private var backgroundBinding: Binding<FocusBackgroundStyle> {
        Binding(
            get: { viewModel.settings.backgroundStyle },
            set: { viewModel.updateBackgroundStyle($0) }
        )
    }

    private func settingRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(FocusPalette.textSecondary)
        }
    }
}
