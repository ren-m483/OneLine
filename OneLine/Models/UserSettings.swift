import Foundation
import SwiftData

@Model
final class UserSettings {
    var notificationsEnabled: Bool
    var notificationHour: Int
    var notificationMinute: Int

    var faceIdEnabled: Bool

    // アプリアイコン系（必要なら）
    var iconBadgeEnabled: Bool
    var iconAutoChangeEnabled: Bool

    // 追加：ユーザーアバター
    var userAvatarData: Data?
    // 追加：開始日（初回作成時にセット）
    var startDate: Date

    init() {
        self.notificationsEnabled = false
        self.notificationHour = 20
        self.notificationMinute = 0
        self.faceIdEnabled = false
        self.iconBadgeEnabled = true
        self.iconAutoChangeEnabled = true

        self.userAvatarData = nil
        self.startDate = Date()
    }
}
