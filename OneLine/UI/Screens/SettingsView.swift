import SwiftUI
import SwiftData
import UserNotifications
import PhotosUI
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [UserSettings]
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]
    @Query private var earnedBadges: [EarnedBadge]

    @State private var notifEnabled: Bool = false
    @State private var notifTime: Date = Date()
    @State private var faceIdEnabled: Bool = false
    @State private var iconBadgeEnabled: Bool = false
    @State private var iconAuto: Bool = false

    @State private var message: String?

    private var settings: UserSettings {
        if let s = settingsList.first { return s }
        let s = UserSettings()
        modelContext.insert(s)
        return s
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("通知") {
                    Toggle("リマインド", isOn: $notifEnabled)
                    DatePicker("時刻", selection: $notifTime, displayedComponents: .hourAndMinute)
                        .disabled(!notifEnabled)
                    if let message {
                        Text(message).foregroundStyle(.secondary)
                    }
                }

                Section("ロック") {
                    Toggle("Face IDでロック", isOn: $faceIdEnabled)
                }
            }
            .navigationTitle("設定")
            .onAppear {
                load()
                Task { await syncNotificationAuthorization() }
            }
            .onChange(of: notifEnabled) { _, newValue in
                if newValue {
                    // トグルON → 設定アプリの通知画面へ
                    openAppNotificationSettings()
                }
                saveAndApply()
            }
            .onChange(of: notifTime) { _, _ in saveAndApply() }
            .onChange(of: faceIdEnabled) { _, _ in saveAndApply() }
            .onChange(of: iconBadgeEnabled) { _, _ in saveAndApply() }
            .onChange(of: iconAuto) { _, _ in saveAndApply() }
        }
    }

    private func load() {
        notifEnabled = settings.notificationsEnabled
        var comps = DateComponents()
        comps.hour = settings.notificationHour
        comps.minute = settings.notificationMinute
        notifTime = Calendar.current.date(from: comps) ?? Date()

        faceIdEnabled = settings.faceIdEnabled
        iconBadgeEnabled = settings.iconBadgeEnabled
        iconAuto = settings.iconAutoChangeEnabled
    }
    
    private func openAppNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func saveAndApply() {
        settings.notificationsEnabled = notifEnabled
        settings.faceIdEnabled = faceIdEnabled
        settings.iconBadgeEnabled = iconBadgeEnabled
        settings.iconAutoChangeEnabled = iconAuto

        let comps = Calendar.current.dateComponents([.hour, .minute], from: notifTime)
        settings.notificationHour = comps.hour ?? 20
        settings.notificationMinute = comps.minute ?? 0

        try? modelContext.save()

        Task {
            if notifEnabled {
                let granted = await NotificationService.requestAuthorization()
                if granted {
                    await NotificationService.scheduleDailyReminder(
                        hour: settings.notificationHour,
                        minute: settings.notificationMinute
                    )
                    message = "通知を設定しました。"
                } else {
                    message = "通知が許可されていません（設定から許可してください）。"
                }
            } else {
                await NotificationService.removeDailyReminder()
                message = "通知をオフにしました。"
            }

            if iconAuto {
                let count = earnedBadges.count
                let name = AppIconService.autoIconName(earnedCount: count)
                AppIconService.setIconIfPossible(name: name)
            } else {
                // 自動OFFの場合はPrimaryに戻す挙動にするなら以下
                // AppIconService.setIconIfPossible(name: nil)
            }
        }
    }
    
    private func syncNotificationAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let granted = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)

        await MainActor.run {
            if !granted {
                notifEnabled = false
                self.settings.notificationsEnabled = false
                try? modelContext.save()
            }
        }
    }
}
