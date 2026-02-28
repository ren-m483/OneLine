import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [UserSettings]

    @State private var isUnlocked: Bool = false
    @State private var showSplash: Bool = true

    private var settings: UserSettings {
        if let s = settingsList.first { return s }
        let s = UserSettings()
        modelContext.insert(s)
        return s
    }

    var body: some View {
        ZStack {
            MainHostView(settings: settings, isUnlocked: $isUnlocked)
                .opacity(showSplash ? 0.0 : 1.0)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSplash = false
                }
            }
        }
    }
}

private struct MainHostView: View {
    let settings: UserSettings
    @Binding var isUnlocked: Bool

    var body: some View {
        if settings.faceIdEnabled {
            LockGateView(isUnlocked: $isUnlocked) {
                MainTabView()
            }
        } else {
            MainTabView()
        }
    }
}

private enum RootTab: Hashable { case calendar, today, settings }

private struct MainTabView: View {
    @State private var tab: RootTab = .today

    var body: some View {
        TabView(selection: $tab) {
            CalendarDecoratedView()
                .tabItem { Label("カレンダー", systemImage: "calendar") }
                .tag(RootTab.calendar)

            TodayView()
                .tabItem { Label("今日の日記", systemImage: "book") }
                .tag(RootTab.today)

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(RootTab.settings)
        }
        .onChange(of: tab) { _, newValue in
            if newValue == .calendar {
                NotificationCenter.default.post(name: .calendarTabSelected, object: nil)
            }
        }
    }
}
