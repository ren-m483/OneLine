import SwiftUI
import SwiftData

@main
struct OneLineApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.font, .custom("HanazonoMincho", size: 17))
        }
        .modelContainer(for: [
            DiaryEntry.self,
            EarnedBadge.self,
            UserSettings.self
        ])
    }
}
