import CoreGraphics
import Foundation

enum FocusKeys {
    static let appGroupID = "group.com.focustime.focustime"
    static let widgetKind = "FocusTimeWidget"

    static let schemaVersion = 1
    static let schemaVersionKey = "ft.schemaVersion"
    static let settingsKey = "ft.settings"
    static let daysKey = "ft.days"
    static let streakKey = "ft.streak"
    static let lastUpdatedKey = "ft.lastUpdated"
    static let activePhaseKey = "ft.activePhase"

    static let defaultFocusMinutes = 25
    static let defaultBreakMinutes = 5
    static let checkpointInterval = 60
}

enum FocusWindowMetrics {
    static let defaultWidth: CGFloat = 332
    static let defaultHeight: CGFloat = 332
    static let edgeInset: CGFloat = 18
    static let panelCornerRadius: CGFloat = 26
}

extension Notification.Name {
    static let focusSettingsDidChange = Notification.Name("FocusTime.settingsDidChange")
}
