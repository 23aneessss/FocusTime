import SwiftUI
import WidgetKit

@main
struct FocusTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusTimeWidget()
    }
}

struct FocusTimeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: FocusKeys.widgetKind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("FocusTime")
        .description("Today's focus time, sessions, streak, and a compact pixel ring.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
