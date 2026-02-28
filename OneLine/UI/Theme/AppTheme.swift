import SwiftUI

enum AppTheme {
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)

    // ほんのり色を入れる（おしゃれの鍵）
    static let accent = Color(red: 0.35, green: 0.60, blue: 0.95)      // パステルブルー
    static let accent2 = Color(red: 0.55, green: 0.82, blue: 0.70)     // ミント
    static let corner: CGFloat = 22
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}
