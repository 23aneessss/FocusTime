import SwiftUI

enum FocusPalette {
    static let chrome = Color(red: 0.16, green: 0.19, blue: 0.26)
    static let chromeBorder = Color(red: 0.28, green: 0.32, blue: 0.41)
    static let textPrimary = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let textSecondary = Color(red: 0.77, green: 0.82, blue: 0.90)
    static let panelFill = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let panelStroke = Color(red: 0.86, green: 0.89, blue: 0.94)
    static let cardShadow = Color.black.opacity(0.22)
    static let widgetBackground = Color(red: 0.13, green: 0.16, blue: 0.21)
    static let timerText = Color(red: 0.17, green: 0.20, blue: 0.28)
    static let centerInnerGlow = Color.white.opacity(0.55)

    static func accent(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.28, green: 0.78, blue: 0.98)
        case .break:
            return Color(red: 0.98, green: 0.52, blue: 0.69)
        }
    }

    static func ringActive(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.24, green: 0.72, blue: 0.99)
        case .break:
            return Color(red: 1.00, green: 0.57, blue: 0.77)
        }
    }

    static func ringHighlight(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.72, green: 0.93, blue: 1.00)
        case .break:
            return Color(red: 1.00, green: 0.84, blue: 0.90)
        }
    }

    static func ringShadow(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.11, green: 0.38, blue: 0.59)
        case .break:
            return Color(red: 0.63, green: 0.26, blue: 0.39)
        }
    }

    static func ringInactive(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color(red: 0.78, green: 0.86, blue: 0.94).opacity(0.28)
        case .break:
            return Color(red: 0.93, green: 0.84, blue: 0.89).opacity(0.26)
        }
    }

    static func centerFill(for phase: TimerPhase) -> Color {
        switch phase {
        case .focus:
            return Color.white.opacity(0.96)
        case .break:
            return Color(red: 0.99, green: 0.96, blue: 0.98)
        }
    }

    static func skyGradient(for date: Date, phase: TimerPhase, style: FocusBackgroundStyle) -> [Color] {
        let hour = Calendar.current.component(.hour, from: date)
        let autoNight = phase == .break || hour < 6 || hour >= 19

        switch style {
        case .blueSkies:
            if autoNight {
                return [
                    Color(red: 0.20, green: 0.18, blue: 0.34),
                    Color(red: 0.32, green: 0.28, blue: 0.43),
                    Color(red: 0.48, green: 0.48, blue: 0.62)
                ]
            }

            return [
                Color(red: 0.39, green: 0.62, blue: 0.99),
                Color(red: 0.63, green: 0.76, blue: 0.98),
                Color(red: 0.91, green: 0.96, blue: 0.99)
            ]
        case .peachSunset:
            return [
                Color(red: 0.52, green: 0.52, blue: 0.88),
                Color(red: 0.98, green: 0.73, blue: 0.68),
                Color(red: 1.00, green: 0.88, blue: 0.77)
            ]
        case .candyClouds:
            return [
                Color(red: 0.96, green: 0.50, blue: 0.72),
                Color(red: 0.99, green: 0.70, blue: 0.81),
                Color(red: 1.00, green: 0.90, blue: 0.92)
            ]
        case .moonNight:
            return [
                Color(red: 0.20, green: 0.18, blue: 0.34),
                Color(red: 0.32, green: 0.28, blue: 0.43),
                Color(red: 0.48, green: 0.48, blue: 0.62)
            ]
        }
    }

    static func cloudFill(for style: FocusBackgroundStyle, phase: TimerPhase) -> Color {
        switch style {
        case .blueSkies:
            return phase == .break ? Color.white.opacity(0.86) : Color.white.opacity(0.93)
        case .peachSunset:
            return Color(red: 1.00, green: 0.95, blue: 0.96).opacity(0.92)
        case .candyClouds:
            return Color(red: 1.00, green: 0.94, blue: 0.97).opacity(0.92)
        case .moonNight:
            return Color.white.opacity(0.88)
        }
    }

    static func cloudShadow(for style: FocusBackgroundStyle, phase: TimerPhase) -> Color {
        switch style {
        case .blueSkies:
            return phase == .break ? Color.black.opacity(0.18) : Color(red: 0.72, green: 0.80, blue: 0.94).opacity(0.55)
        case .peachSunset:
            return Color(red: 0.84, green: 0.60, blue: 0.71).opacity(0.55)
        case .candyClouds:
            return Color(red: 0.90, green: 0.74, blue: 0.83).opacity(0.58)
        case .moonNight:
            return Color.black.opacity(0.26)
        }
    }
}

enum FocusTypography {
    private static let fontResourceName = "PressStart2P-Regular"

    static func pixel(size: CGFloat) -> Font {
        if Bundle.main.url(forResource: fontResourceName, withExtension: "ttf") != nil {
            return .custom(fontResourceName, size: size)
        }

        return .system(size: size, weight: .black, design: .monospaced)
    }

    static func phase(size: CGFloat) -> Font {
        if Bundle.main.url(forResource: fontResourceName, withExtension: "ttf") != nil {
            return .custom(fontResourceName, size: size)
        }

        return .system(size: size, weight: .heavy, design: .rounded)
    }

    static func timer(size: CGFloat) -> Font {
        if Bundle.main.url(forResource: fontResourceName, withExtension: "ttf") != nil {
            return .custom(fontResourceName, size: size)
        }

        return .system(size: size, weight: .black, design: .rounded)
    }

    static func body(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
