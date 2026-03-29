import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

final class DataStore {
    static let shared = DataStore()

    private let queue = DispatchQueue(label: "FocusTime.DataStore")
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = UserDefaults(suiteName: FocusKeys.appGroupID)) {
        self.defaults = defaults ?? .standard
        bootstrap()
    }

    func loadSettings() -> FocusSettings {
        queue.sync {
            decode(FocusSettings.self, forKey: FocusKeys.settingsKey) ?? .default
        }
    }

    func saveSettings(_ settings: FocusSettings) {
        queue.sync {
            encode(settings, forKey: FocusKeys.settingsKey)
            defaults.set(Date().timeIntervalSince1970, forKey: FocusKeys.lastUpdatedKey)
            defaults.set(FocusKeys.schemaVersion, forKey: FocusKeys.schemaVersionKey)
        }

        NotificationCenter.default.post(name: .focusSettingsDidChange, object: self)
        requestWidgetReload()
    }

    func loadCurrentPhase() -> TimerPhase {
        queue.sync {
            guard let value = defaults.string(forKey: FocusKeys.activePhaseKey),
                  let phase = TimerPhase(rawValue: value) else {
                return .focus
            }

            return phase
        }
    }

    func saveCurrentPhase(_ phase: TimerPhase, reloadWidget: Bool = false) {
        queue.sync {
            defaults.set(phase.rawValue, forKey: FocusKeys.activePhaseKey)
            defaults.set(Date().timeIntervalSince1970, forKey: FocusKeys.lastUpdatedKey)
        }

        if reloadWidget {
            requestWidgetReload()
        }
    }

    func todayStats(for date: Date = .now) -> DailyStats {
        queue.sync {
            let dayKey = FocusFormatters.dayKey(for: date)
            let days = loadDaysLocked()
            return days[dayKey] ?? DailyStats()
        }
    }

    func snapshot(for date: Date = .now) -> FocusWidgetSnapshot {
        queue.sync {
            let settings = decode(FocusSettings.self, forKey: FocusKeys.settingsKey) ?? .default
            let days = loadDaysLocked()
            let today = days[FocusFormatters.dayKey(for: date)] ?? DailyStats()
            let streak = computeStreak(days: days, referenceDate: date)
            let phase = TimerPhase(rawValue: defaults.string(forKey: FocusKeys.activePhaseKey) ?? "") ?? .focus

            return FocusWidgetSnapshot(
                capturedAt: date,
                todaySeconds: today.seconds,
                todaySessions: today.sessions,
                streak: streak,
                focusDuration: settings.focusDuration,
                phase: phase,
                backgroundStyle: settings.backgroundStyle
            )
        }
    }

    @discardableResult
    func commitFocusProgress(
        seconds: Int,
        completedSession: Bool,
        on date: Date = .now,
        reloadWidget: Bool = false
    ) -> DailyStats {
        let stats = queue.sync {
            let clampedSeconds = max(0, seconds)
            let dayKey = FocusFormatters.dayKey(for: date)
            var days = loadDaysLocked()
            var today = days[dayKey] ?? DailyStats()

            if clampedSeconds > 0 {
                today.seconds += clampedSeconds
            }

            if completedSession {
                today.sessions += 1
            }

            days[dayKey] = today
            saveDaysLocked(days)

            let streak = computeStreak(days: days, referenceDate: date)
            defaults.set(streak, forKey: FocusKeys.streakKey)
            defaults.set(Date().timeIntervalSince1970, forKey: FocusKeys.lastUpdatedKey)
            defaults.set(FocusKeys.schemaVersion, forKey: FocusKeys.schemaVersionKey)

            return today
        }

        if completedSession || reloadWidget {
            requestWidgetReload()
        }

        return stats
    }

    func currentStreak(referenceDate: Date = .now) -> Int {
        queue.sync {
            let days = loadDaysLocked()
            let streak = computeStreak(days: days, referenceDate: referenceDate)
            defaults.set(streak, forKey: FocusKeys.streakKey)
            return streak
        }
    }

    func requestWidgetReload() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func bootstrap() {
        queue.sync {
            defaults.set(FocusKeys.schemaVersion, forKey: FocusKeys.schemaVersionKey)

            if defaults.data(forKey: FocusKeys.settingsKey) == nil {
                encode(FocusSettings.default, forKey: FocusKeys.settingsKey)
            }

            if defaults.data(forKey: FocusKeys.daysKey) == nil {
                encode([String: DailyStats](), forKey: FocusKeys.daysKey)
            }

            if defaults.string(forKey: FocusKeys.activePhaseKey) == nil {
                defaults.set(TimerPhase.focus.rawValue, forKey: FocusKeys.activePhaseKey)
            }
        }
    }

    private func loadDaysLocked() -> [String: DailyStats] {
        decode([String: DailyStats].self, forKey: FocusKeys.daysKey) ?? [:]
    }

    private func saveDaysLocked(_ days: [String: DailyStats]) {
        encode(days, forKey: FocusKeys.daysKey)
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func computeStreak(days: [String: DailyStats], referenceDate: Date) -> Int {
        let calendar = Calendar.current
        let todayKey = FocusFormatters.dayKey(for: referenceDate, calendar: calendar)
        let todayHasSessions = (days[todayKey]?.sessions ?? 0) > 0
        let anchorDate = todayHasSessions
            ? referenceDate
            : (calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate)

        var streak = 0
        var cursor = anchorDate

        while true {
            let key = FocusFormatters.dayKey(for: cursor, calendar: calendar)
            guard let stats = days[key], stats.sessions > 0 else { break }
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }
}
