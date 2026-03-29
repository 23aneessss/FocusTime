import WidgetKit

struct Provider: TimelineProvider {
    private let store = WidgetDataStore.shared

    func placeholder(in context: Context) -> FocusTimeEntry {
        store.placeholderEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusTimeEntry) -> Void) {
        completion(store.makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusTimeEntry>) -> Void) {
        let entry = store.makeEntry()
        // Keep the widget on a conservative schedule and rely on app-driven reloads for major changes.
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: entry.date) ?? entry.date.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}
