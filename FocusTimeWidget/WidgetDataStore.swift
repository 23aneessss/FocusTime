import Foundation

struct WidgetDataStore {
    static let shared = WidgetDataStore()

    func makeEntry(for date: Date = .now) -> FocusTimeEntry {
        FocusTimeEntry(date: date, snapshot: DataStore.shared.snapshot(for: date))
    }

    func placeholderEntry() -> FocusTimeEntry {
        FocusTimeEntry(date: .now, snapshot: .placeholder)
    }
}
