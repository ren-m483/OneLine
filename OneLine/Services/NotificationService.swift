import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) async {
        // 既存を削除して再登録
        await removeDailyReminder()

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "1行日記"
        content.body = "今日の1行、残しておきませんか？"
        content.sound = .default

        // バッジは「未投稿なら1」にする運用（数字の意味がブレない）
        // streak数をホーム画面赤バッジに出すのはUX好みが分かれるので、MVPは1推奨
        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        do { try await UNUserNotificationCenter.current().add(request) } catch { }
    }

    static func removeDailyReminder() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    static func clearAppBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

extension Notification.Name {
    static let calendarTabSelected = Notification.Name("calendarTabSelected")
}
