import Foundation
import SwiftUI

enum BadgeLevel: String, CaseIterable, Identifiable {
    case ss = "SS", s = "S", a = "A", b = "B", c = "C", d = "D"
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .ss: return Color(red: 0.95, green: 0.60, blue: 0.20) // gold
        case .s:  return Color(red: 0.55, green: 0.75, blue: 0.95) // sky
        case .a:  return Color(red: 0.55, green: 0.85, blue: 0.70) // mint
        case .b:  return Color(red: 0.70, green: 0.65, blue: 0.90) // lavender
        case .c:  return Color(red: 0.80, green: 0.80, blue: 0.85) // gray
        case .d:  return Color(red: 0.88, green: 0.88, blue: 0.90) // light gray
        }
    }
}

struct BadgeDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let level: BadgeLevel
}
