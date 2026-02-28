import UIKit

enum AppIconService {
    static func setIconIfPossible(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(name) { _ in }
    }

    /// バッジ獲得数に応じて自動切替する例（任意）
    static func autoIconName(earnedCount: Int) -> String? {
        // nil = Primary icon
        if earnedCount >= 75 { return "IconGold" }
        if earnedCount >= 25 { return "IconSilver" }
        if earnedCount >= 10 { return "IconBronze" }
        return nil
    }
}
