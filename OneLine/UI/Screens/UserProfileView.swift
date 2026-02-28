import SwiftUI
import SwiftData
import PhotosUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [UserSettings]
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]

    @State private var picker: PhotosPickerItem?

    private var settings: UserSettings {
        if let s = settingsList.first { return s }
        let s = UserSettings()
        modelContext.insert(s)
        return s
    }

    private var streak: Int { StreakCalculator.currentStreak(entries: entries) }
    private var tier: Tier { Tier.from(streak: streak) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {

                        // 大きい丸（画像が全面に入る）
                        ZStack(alignment: .bottomTrailing) {
                            LargeAvatarView(
                                avatarData: settings.userAvatarData,
                                ringColor: tier.ringColor,
                                size: 260
                            )

                            PhotosPicker(selection: $picker, matching: .images) {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(Color.blue.opacity(0.85))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            }
                            .padding(6)
                        }
                        .padding(.top, 20)

                        Text("\(formatDate(settings.startDate))から開始")
                            .font(.custom("HanazonoMincho", size: 34))

                        Text("\(tierText(tier))ランク")
                            .font(.custom("HanazonoMincho", size: 20))
                            .foregroundStyle(.secondary)

                        Text("連続更新\(streak)日目")
                            .font(.custom("HanazonoMincho", size: 26))

                        Spacer(minLength: 30)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
            .onChange(of: picker) { _, newValue in
                Task {
                    guard let newValue else { return }
                    if let data = try? await newValue.loadTransferable(type: Data.self) {
                        settings.userAvatarData = data
                        try? modelContext.save() // ← これで左上アイコンも更新される
                    }
                }
            }
        }
    }

    private func formatDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/M/d"
        return f.string(from: d)
    }

    private func tierText(_ t: Tier) -> String {
        switch t {
        case .gray: return "グレー"
        case .bronze: return "ブロンズ"
        case .silver: return "シルバー"
        case .gold: return "ゴールド"
        }
    }
}

private struct LargeAvatarView: View {
    let avatarData: Data?
    let ringColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor, lineWidth: 6)
                .frame(width: size, height: size)

            if let avatarData, let ui = UIImage(data: avatarData) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 12, height: size - 12)
                    .clipped()
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: size - 12, height: size - 12)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(.secondary)
                    )
            }
        }
    }
}
