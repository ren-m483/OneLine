import SwiftUI

enum Tier: String {
    case gray, bronze, silver, gold

    static func from(streak: Int) -> Tier {
        if streak >= 30 { return .gold }
        if streak >= 14 { return .silver }
        if streak >= 7  { return .bronze }
        return .gray
    }

    var ringColor: Color {
        switch self {
        case .gray:   return Color(.systemGray3)
        case .bronze: return Color(red: 0.72, green: 0.46, blue: 0.25)
        case .silver: return Color(red: 0.62, green: 0.65, blue: 0.72)
        case .gold:   return Color(red: 0.86, green: 0.74, blue: 0.30)
        }
    }
}

struct AvatarRingView: View {
    let avatarData: Data?
    let tier: Tier

    var body: some View {
        ZStack {
            Circle().stroke(tier.ringColor, lineWidth: 4)
                .frame(width: 44, height: 44)

            if let avatarData, let ui = UIImage(data: avatarData) {
                Image(uiImage: ui)
                    .resizable().scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
            } else {
                Circle().fill(Color(.tertiarySystemFill))
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
            }
        }
    }
}
