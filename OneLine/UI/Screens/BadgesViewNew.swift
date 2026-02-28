import SwiftUI
import SwiftData

struct BadgesViewNew: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \EarnedBadge.earnedAt, order: .reverse) private var earned: [EarnedBadge]

    private var earnedSet: Set<String> { Set(earned.map { $0.id }) }
    private var quote: Quote { DailyQuoteProvider.quote() }

    // 代表閾値（例）
    private let streakTargets = [1,3,7,10,14,21,30,50,60,100,120,200,250,300,500,1000]
    private let totalTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]
    private let photoTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]
    private let titleTargets  = [1,3,10,20,30,50,75,100,150,200,300,500,1000,1500,2000]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        quoteCard

                        section(title: "連続投稿", ids: streakTargets.map { "streak_\($0)" })
                        section(title: "累計投稿", ids: totalTargets.map { "total_\($0)" })
                        section(title: "写真枚数", ids: photoTargets.map { "photo_\($0)" })
                        section(title: "タイトル回数", ids: titleTargets.map { "titled_\($0)" })
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("“\(quote.text)”")
                .font(.custom("HanazonoMincho", size: 18))
            Text("— \(quote.author)")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 24)
    }

    private func section(title: String, ids: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("HanazonoMincho", size: 20))
                .padding(.horizontal, 16)

            ForEach(ids, id: \.self) { id in
                let def = BadgeEngine.definition(for: id)
                BadgeRowSimple(
                    title: def?.title ?? id,
                    level: def?.level ?? .d,
                    isEarned: earnedSet.contains(id)
                )
            }
        }
    }
}

private struct BadgeRowSimple: View {
    let title: String
    let level: BadgeLevel
    let isEarned: Bool

    var tierColor: Color {
        // グレー/ブロンズ/シルバー/ゴールド
        switch level {
        case .ss, .s: return Color(red: 0.86, green: 0.74, blue: 0.30) // gold
        case .a:      return Color(red: 0.62, green: 0.65, blue: 0.72) // silver
        case .b:      return Color(red: 0.72, green: 0.46, blue: 0.25) // bronze
        case .c, .d:  return Color(.systemGray3)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if isEarned {
                Image(systemName: "rosette")
                    .foregroundStyle(tierColor)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 30)
            } else {
                Spacer().frame(width: 30)
            }

            Text(title)
                .font(.custom("HanazonoMincho", size: 18))
                .foregroundStyle(isEarned ? .primary : .secondary)

            Spacer()

            Text(level.rawValue)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isEarned ? tierColor.opacity(0.15) : Color(.tertiarySystemFill))
                .clipShape(Capsule())
                .foregroundStyle(isEarned ? .primary : .secondary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
}
