import Foundation

enum BadgeEngine {

    // 画面側と同じ段階（ここを唯一のソースにする）
    private static let streakTargets = [1,3,7,10,14,21,30,50,60,100,120,200,250,300,500,1000]
    private static let totalTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]
    private static let photoTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]
    private static let titleTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]

    // すべての定義（指定した段階のみ）
    static func allDefinitions() -> [BadgeDefinition] {
        var defs: [BadgeDefinition] = []

        for t in streakTargets {
            defs.append(.init(id: "streak_\(t)", title: "連続\(t)日", level: levelForStreak(t)))
        }
        for t in totalTargets {
            defs.append(.init(id: "total_\(t)", title: "累計\(t)回", level: levelForTotal(t)))
        }
        for t in photoTargets {
            defs.append(.init(id: "photo_\(t)", title: "写真\(t)枚", level: levelForPhoto(t)))
        }
        for t in titleTargets {
            defs.append(.init(id: "titled_\(t)", title: "タイトル\(t)回", level: levelForTitle(t)))
        }

        // 表示順（任意）：streak→total→photo→titled、昇順
        return defs
    }

    // definition(for:) はこれ1つだけ（重複禁止）
    static func definition(for id: String) -> BadgeDefinition? {
        allDefinitions().first(where: { $0.id == id })
    }

    // 獲得判定：指定段階のバッジだけを判定
    static func newlyEarned(
        entries: [DiaryEntry],
        alreadyEarned: Set<String>
    ) -> [String] {
        let streak = StreakCalculator.currentStreak(entries: entries)
        let total = entries.count

        // 写真枚数：メイン(1) + サブ枚数 の合計
        let photoCount = entries.reduce(0) { acc, e in
            acc + (e.mainPhotoData == nil ? 0 : 1) + e.subPhotoDataList.count
        }

        // タイトル付けた回数
        let titledCount = entries.filter {
            !($0.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }.count

        var earnedNow: [String] = []

        // 連続
        for t in streakTargets where streak >= t {
            let id = "streak_\(t)"
            if !alreadyEarned.contains(id) { earnedNow.append(id) }
        }
        // 累計
        for t in totalTargets where total >= t {
            let id = "total_\(t)"
            if !alreadyEarned.contains(id) { earnedNow.append(id) }
        }
        // 写真
        for t in photoTargets where photoCount >= t {
            let id = "photo_\(t)"
            if !alreadyEarned.contains(id) { earnedNow.append(id) }
        }
        // タイトル
        for t in titleTargets where titledCount >= t {
            let id = "titled_\(t)"
            if !alreadyEarned.contains(id) { earnedNow.append(id) }
        }

        // たくさん獲得した場合の順序（任意）：大きい達成から出したいなら reversed() にする
        // ここでは小→大で返す
        return earnedNow
    }

    // MARK: - Level rules（段階に合わせて調整）
    // ※ SS/S/A/B/C/D を使う前提。必要なら閾値を調整してください。

    private static func levelForStreak(_ t: Int) -> BadgeLevel {
        switch t {
        case 500...: return .ss
        case 250...499: return .s
        case 120...249: return .a
        case 50...119: return .b
        case 10...49: return .c
        default: return .d
        }
    }

    private static func levelForTotal(_ t: Int) -> BadgeLevel {
        switch t {
        case 1500...: return .ss
        case 1000...1499: return .s
        case 300...999: return .a
        case 100...299: return .b
        case 30...99: return .c
        default: return .d
        }
    }

    private static func levelForPhoto(_ t: Int) -> BadgeLevel {
        switch t {
        case 1000...: return .ss
        case 500...999: return .s
        case 200...499: return .a
        case 75...199: return .b
        case 20...74: return .c
        default: return .d
        }
    }

    private static func levelForTitle(_ t: Int) -> BadgeLevel {
        switch t {
        case 1000...: return .ss
        case 500...999: return .s
        case 200...499: return .a
        case 75...199: return .b
        case 20...74: return .c
        default: return .d
        }
    }
}
