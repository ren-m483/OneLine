import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]
    @Query private var settingsList: [UserSettings]

    @State private var showEditor = false
    @State private var showSearch = false
    @State private var showBadges = false
    @State private var showUser = false

    @State private var now: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var todayKey: String { DateProvider.todayKey() }
    private var todayEntry: DiaryEntry? { entries.first(where: { $0.dateKey == todayKey }) }
    private var streak: Int { StreakCalculator.currentStreak(entries: entries) }

    private var settings: UserSettings {
        if let s = settingsList.first { return s }
        let s = UserSettings()
        modelContext.insert(s)
        return s
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .bottomTrailing) {
                    PhotoBackground(
                        data: todayEntry?.mainPhotoData,
                        fallbackAssetName: "background" // Assets名
                    )
                    
                    VStack(spacing: 0) {
                        // 上部（日付＋時刻）
                        VStack(spacing: 6) {
                            Text(todayKey.replacingOccurrences(of: "-", with: "/"))
                                .font(.custom("HanazonoMincho", size: 34))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(timeString(now))
                                .font(.custom("HanazonoMincho", size: 102))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .foregroundStyle(todayEntry?.mainPhotoData == nil ? .black.opacity(0.85) : .white.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onReceive(timer) { _ in
                        now = Date()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay(alignment: .center){
                    // 本文カード（ある/なし両方）
                    if let entry = todayEntry {
                        TodayContentCard(entry: entry)
                            .padding(.horizontal, 22)
                            .padding(.top, 22)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 2)
                                    .padding(.horizontal, 22)
                                    .padding(.top, 22)
                            )
                            .onTapGesture { showEditor = true }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if todayEntry == nil {
                        FloatingPillButton(
                            systemImage: "plus",
                            action: { showEditor = true }
                        )
                        .padding(.trailing, 18)
                        .padding(.bottom, 18)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showUser = true } label: {
                        AvatarRingView(
                            avatarData: settings.userAvatarData,
                            tier: Tier.from(streak: streak)
                        )
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button { showBadges = true } label: { Image(systemName: "rosette") }
                        Button { showSearch = true } label: { Image(systemName: "magnifyingglass") }
                    }
                }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.thinMaterial, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
            .tint(todayEntry?.mainPhotoData == nil ? Color.blue : Color.white)
            .sheet(isPresented: $showEditor) { EntryEditorViewNew() }
            .sheet(isPresented: $showSearch) { SearchView() }
            .sheet(isPresented: $showBadges) { BadgesViewNew() }
            .sheet(isPresented: $showUser) { UserProfileView() }
        }
    }
}

private struct TodayContentCard: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(spacing: 14) {

            // タイトル + 下線（テキストと同色）
            VStack(spacing: 10) {
                Text(entry.title?.isEmpty == false ? (entry.title ?? "") : "タイトルなし")
                    .font(.custom("HanazonoMincho", size: 24))
                    .foregroundStyle(.white)

                Rectangle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 220, height: 1)   // 長さは好みで調整
            }

            // 本文
            Text(entry.body)
                .font(.custom("HanazonoMincho", size: 16))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 4)
                .padding(.horizontal, 8)

            // サブ画像：本文の下（右にスクロール）
            if !entry.subPhotoDataList.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(entry.subPhotoDataList.enumerated()), id: \.offset) { _, d in
                            if let ui = UIImage(data: d) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 78, height: 78)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(.white.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .stroke(Color.white.opacity(0.30), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
    }
}

private struct FloatingPillButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.green.opacity(0.55), Color.blue.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

private func timeString(_ date: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ja_JP")
    f.dateFormat = "HH:mm"
    return f.string(from: date)
}
