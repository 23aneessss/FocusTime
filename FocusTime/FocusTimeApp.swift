import SwiftUI

@main
struct FocusTimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = FocusTimerViewModel(dataStore: .shared)

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: FocusWindowMetrics.defaultWidth, height: FocusWindowMetrics.defaultHeight)

        Settings {
            SettingsView(viewModel: viewModel)
        }
        .defaultSize(width: 460, height: 340)
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
