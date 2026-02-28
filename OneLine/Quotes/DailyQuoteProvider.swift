import Foundation

enum DailyQuoteProvider {
    static func quote(for date: Date = Date()) -> Quote {
        let key = DateProvider.key(for: date) // "YYYY-MM-DD"
        let idx = stableIndex(from: key, modulo: max(1, QuoteRepository.all.count))
        return QuoteRepository.all[idx]
    }

    private static func stableIndex(from key: String, modulo: Int) -> Int {
        var hasher = Hasher()
        hasher.combine(key)
        let value = abs(hasher.finalize())
        return value % modulo
    }
}
