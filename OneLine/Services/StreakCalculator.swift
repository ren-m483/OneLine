import Foundation

enum StreakCalculator {
    /// entries: 全件（dateKeyが一意の想定）
    static func currentStreak(entries: [DiaryEntry]) -> Int {
        let set = Set(entries.map { $0.dateKey })
        var streak = 0
        var cursor = DateProvider.date(from: DateProvider.todayKey()) ?? Date()

        while true {
            let key = DateProvider.key(for: cursor)
            if set.contains(key) {
                streak += 1
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
        }
        return streak
    }

    static func totalCount(entries: [DiaryEntry]) -> Int {
        entries.count
    }
}
