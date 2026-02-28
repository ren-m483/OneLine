import Foundation
import SwiftData

@Model
final class EarnedBadge {
    @Attribute(.unique) var id: String
    var earnedAt: Date

    init(id: String, earnedAt: Date = Date()) {
        self.id = id
        self.earnedAt = earnedAt
    }
}
