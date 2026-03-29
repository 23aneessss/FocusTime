import AppKit
import Combine
import Foundation

@MainActor
final class FocusTimerViewModel: ObservableObject {
    @Published private(set) var phase: TimerPhase
    @Published private(set) var isRunning = false
    @Published private(set) var secondsRemaining: Int
    @Published private(set) var todayStats: DailyStats
    @Published private(set) var streak: Int
    @Published private(set) var settings: FocusSettings

    private let dataStore: DataStore
    private var timerTask: Task<Void, Never>?
    private var pendingFocusSeconds = 0

    init(dataStore: DataStore) {
        let loadedSettings = dataStore.loadSettings()
        let loadedPhase = dataStore.loadCurrentPhase()
        let loadedTodayStats = dataStore.todayStats()
        let loadedStreak = dataStore.currentStreak()

        self.dataStore = dataStore
        self.settings = loadedSettings
        self.phase = loadedPhase
        self.todayStats = loadedTodayStats
        self.streak = loadedStreak
        self.secondsRemaining = loadedPhase.duration(using: loadedSettings)
    }

    convenience init() {
        self.init(dataStore: .shared)
    }

    deinit {
        timerTask?.cancel()
    }

    var progress: Double {
        let duration = phase.duration(using: settings)
        guard duration > 0 else { return 0 }
        return 1 - (Double(secondsRemaining) / Double(duration))
    }

    var timeLabel: String {
        FocusFormatters.clockString(from: secondsRemaining)
    }

    var primaryActionLabel: String {
        isRunning ? "Pause" : "Start"
    }

    var todayFocusLabel: String {
        FocusFormatters.shortDurationString(from: todayStats.seconds + pendingFocusSeconds)
    }

    var timerAccessibilityValue: String {
        let state = isRunning ? "running" : "paused"
        return "\(phase.title) timer, \(state), \(FocusFormatters.accessibilityDurationString(from: secondsRemaining)) remaining"
    }

    func toggleTimer() {
        isRunning ? pauseTimer(flushPending: true) : startTimer()
    }

    func resetTimer() {
        let flushed = flushPendingFocusProgress(reloadWidget: false)
        stopTimer()
        secondsRemaining = phase.duration(using: settings)
        refreshSnapshot()

        if flushed > 0 {
            dataStore.requestWidgetReload()
        }
    }

    func skipPhase() {
        let flushed = flushPendingFocusProgress(reloadWidget: false)
        let shouldResume = isRunning

        stopTimer()
        phase = phase.next
        dataStore.saveCurrentPhase(phase, reloadWidget: true)
        secondsRemaining = phase.duration(using: settings)
        refreshSnapshot()

        if flushed > 0 {
            dataStore.requestWidgetReload()
        }

        if shouldResume {
            startTimer()
        }
    }

    func updateFocusDuration(minutes: Int) {
        mutateSettings { $0.focusDuration = minutes * 60 }
    }

    func updateBreakDuration(minutes: Int) {
        mutateSettings { $0.breakDuration = minutes * 60 }
    }

    func updateSoundEnabled(_ enabled: Bool) {
        mutateSettings { $0.soundEnabled = enabled }
    }

    func updateReduceMotion(_ enabled: Bool) {
        mutateSettings { $0.reduceMotion = enabled }
    }

    func updatePreferredCorner(_ corner: FocusCorner) {
        mutateSettings { $0.preferredCorner = corner }
    }

    func updateBackgroundStyle(_ style: FocusBackgroundStyle) {
        mutateSettings { $0.backgroundStyle = style }
    }

    private func mutateSettings(_ mutation: (inout FocusSettings) -> Void) {
        var updated = settings
        mutation(&updated)
        guard updated != settings else { return }

        settings = updated
        dataStore.saveSettings(updated)

        if !isRunning {
            secondsRemaining = phase.duration(using: updated)
        }
    }

    private func startTimer() {
        guard !isRunning else { return }

        isRunning = true
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await self.tick()
            }
        }
    }

    private func stopTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    private func pauseTimer(flushPending: Bool) {
        stopTimer()

        if flushPending {
            _ = flushPendingFocusProgress(reloadWidget: false)
            refreshSnapshot()
        }
    }

    private func tick() {
        guard isRunning else { return }

        if secondsRemaining > 0 {
            secondsRemaining -= 1
        }

        if phase == .focus {
            pendingFocusSeconds += 1

            if pendingFocusSeconds >= FocusKeys.checkpointInterval {
                _ = flushPendingFocusProgress(reloadWidget: false)
                refreshSnapshot()
            }
        }

        if secondsRemaining == 0 {
            completePhase()
        }
    }

    private func completePhase() {
        let completedPhase = phase
        _ = flushPendingFocusProgress(reloadWidget: false)

        if completedPhase == .focus {
            todayStats = dataStore.commitFocusProgress(seconds: 0, completedSession: true, reloadWidget: true)
            streak = dataStore.currentStreak()
            playCompletionSoundIfNeeded()
        }

        phase = completedPhase.next
        dataStore.saveCurrentPhase(phase)
        secondsRemaining = phase.duration(using: settings)
        refreshSnapshot()
    }

    @discardableResult
    private func flushPendingFocusProgress(reloadWidget: Bool) -> Int {
        guard pendingFocusSeconds > 0 else { return 0 }

        let seconds = pendingFocusSeconds
        pendingFocusSeconds = 0
        todayStats = dataStore.commitFocusProgress(seconds: seconds, completedSession: false, reloadWidget: reloadWidget)
        streak = dataStore.currentStreak()
        return seconds
    }

    private func refreshSnapshot() {
        todayStats = dataStore.todayStats()
        streak = dataStore.currentStreak()
    }

    private func playCompletionSoundIfNeeded() {
        guard settings.soundEnabled else { return }

        if let sound = NSSound(named: NSSound.Name("Glass")) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
