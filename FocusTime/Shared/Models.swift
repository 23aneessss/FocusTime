import Foundation

enum FocusCorner: String, CaseIterable, Codable, Identifiable {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topRight:
            return "Top Right"
        case .topLeft:
            return "Top Left"
        case .bottomRight:
            return "Bottom Right"
        case .bottomLeft:
            return "Bottom Left"
        }
    }
}

enum FocusBackgroundStyle: String, CaseIterable, Codable, Identifiable {
    case blueSkies
    case peachSunset
    case candyClouds
    case moonNight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blueSkies:
            return "Blue Skies"
        case .peachSunset:
            return "Peach Sunset"
        case .candyClouds:
            return "Candy Clouds"
        case .moonNight:
            return "Moon Night"
        }
    }

    // If you later add asset-catalog images with these names, the app will use them automatically.
    var assetName: String {
        switch self {
        case .blueSkies:
            return "BackgroundBlueSkies"
        case .peachSunset:
            return "BackgroundPeachSunset"
        case .candyClouds:
            return "BackgroundCandyClouds"
        case .moonNight:
            return "BackgroundMoonNight"
        }
    }
}

enum TimerPhase: String, CaseIterable, Codable, Identifiable {
    case focus
    case `break`

    var id: String { rawValue }

    var next: TimerPhase {
        self == .focus ? .break : .focus
    }

    var title: String {
        switch self {
        case .focus:
            return "Focus"
        case .break:
            return "Break"
        }
    }

    func duration(using settings: FocusSettings) -> Int {
        switch self {
        case .focus:
            return settings.focusDuration
        case .break:
            return settings.breakDuration
        }
    }
}

struct DailyStats: Codable, Hashable {
    var seconds: Int = 0
    var sessions: Int = 0
}

struct FocusSettings: Codable, Hashable {
    var focusDuration: Int
    var breakDuration: Int
    var soundEnabled: Bool
    var reduceMotion: Bool
    var preferredCorner: FocusCorner
    var backgroundStyle: FocusBackgroundStyle

    private enum CodingKeys: String, CodingKey {
        case focusDuration
        case breakDuration
        case soundEnabled
        case reduceMotion
        case preferredCorner
        case backgroundStyle
    }

    static let `default` = FocusSettings(
        focusDuration: FocusKeys.defaultFocusMinutes * 60,
        breakDuration: FocusKeys.defaultBreakMinutes * 60,
        soundEnabled: true,
        reduceMotion: false,
        preferredCorner: .topRight,
        backgroundStyle: .blueSkies
    )

    init(
        focusDuration: Int,
        breakDuration: Int,
        soundEnabled: Bool,
        reduceMotion: Bool,
        preferredCorner: FocusCorner,
        backgroundStyle: FocusBackgroundStyle
    ) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.soundEnabled = soundEnabled
        self.reduceMotion = reduceMotion
        self.preferredCorner = preferredCorner
        self.backgroundStyle = backgroundStyle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        focusDuration = try container.decodeIfPresent(Int.self, forKey: .focusDuration) ?? FocusSettings.default.focusDuration
        breakDuration = try container.decodeIfPresent(Int.self, forKey: .breakDuration) ?? FocusSettings.default.breakDuration
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? FocusSettings.default.soundEnabled
        reduceMotion = try container.decodeIfPresent(Bool.self, forKey: .reduceMotion) ?? FocusSettings.default.reduceMotion
        preferredCorner = try container.decodeIfPresent(FocusCorner.self, forKey: .preferredCorner) ?? FocusSettings.default.preferredCorner
        backgroundStyle = try container.decodeIfPresent(FocusBackgroundStyle.self, forKey: .backgroundStyle) ?? .blueSkies
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(focusDuration, forKey: .focusDuration)
        try container.encode(breakDuration, forKey: .breakDuration)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(reduceMotion, forKey: .reduceMotion)
        try container.encode(preferredCorner, forKey: .preferredCorner)
        try container.encode(backgroundStyle, forKey: .backgroundStyle)
    }

    var focusMinutes: Int {
        focusDuration / 60
    }

    var breakMinutes: Int {
        breakDuration / 60
    }
}

struct FocusWidgetSnapshot: Codable, Hashable {
    var capturedAt: Date
    var todaySeconds: Int
    var todaySessions: Int
    var streak: Int
    var focusDuration: Int
    var phase: TimerPhase
    var backgroundStyle: FocusBackgroundStyle

    var ringProgress: Double {
        guard focusDuration > 0 else { return 0 }
        return min(max(Double(todaySeconds) / Double(focusDuration), 0), 1)
    }

    static let placeholder = FocusWidgetSnapshot(
        capturedAt: .now,
        todaySeconds: 4_800,
        todaySessions: 3,
        streak: 6,
        focusDuration: FocusKeys.defaultFocusMinutes * 60,
        phase: .focus,
        backgroundStyle: .blueSkies
    )
}
