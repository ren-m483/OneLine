import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct EntryEditorViewNew: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]
    @Query private var earnedBadges: [EarnedBadge]

    @State private var title: String = ""
    @State private var bodyText: String = ""

    @State private var mainPicker: PhotosPickerItem?
    @State private var subPicker: PhotosPickerItem?

    @State private var mainPhotoData: Data?
    @State private var subPhotos: [Data] = []

    @State private var errorMessage: String?
    
    @State private var newBadgeIds: [String] = []
    @State private var showBadgeModal = false

    private var todayKey: String { DateProvider.todayKey() }
    private var todayEntry: DiaryEntry? { entries.first(where: { $0.dateKey == todayKey }) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text(todayKey.replacingOccurrences(of: "-", with: "/"))
                            .font(.system(size: 28, weight: .semibold, design: .serif))
                            .padding(.top, 8)

                        cardTitle
                        cardBody
                        cardPhotos

                        if let errorMessage {
                            Text(errorMessage).foregroundStyle(.red).font(.caption)
                        }

                        Button { save() } label: {
                            Text("保存する")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(colors: [Color.green.opacity(0.55), Color.blue.opacity(0.55)],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("閉じる") { dismiss() } }
            }
            .onAppear { loadIfExists() }
            .onChange(of: mainPicker) { _, newValue in
                Task {
                    guard let newValue else { return }
                    if let d = try? await newValue.loadTransferable(type: Data.self) {
                        mainPhotoData = d
                    }
                }
            }
            .onChange(of: subPicker) { _, newValue in
                Task {
                    guard let newValue else { return }
                    if subPhotos.count >= 5 { return }
                    if let d = try? await newValue.loadTransferable(type: Data.self) {
                        subPhotos.append(d)
                    }
                }
            }
            .sheet(isPresented: $showBadgeModal) {
                BadgeCongratsModalNew {
                    dismiss()
                }
            }
        }
    }

    private var cardTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("タイトル")
                .font(.custom("HanazonoMincho", size: 18))
            TextField("例：ディズニーデート", text: $title)
                .padding(12)
                .font(.custom("HanazonoMincho", size: 16))
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 16)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日記")
                .font(.custom("HanazonoMincho", size: 18))
            TextField("今日の1行", text: $bodyText, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .font(.custom("HanazonoMincho", size: 16))
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 16)
    }

    private var cardPhotos: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("写真")
                .font(.custom("HanazonoMincho", size: 18))

            // メイン
            VStack(alignment: .leading, spacing: 10) {
                Text("メイン")
                    .font(.custom("HanazonoMincho", size: 14))
                    .foregroundStyle(.secondary)

                PhotosPicker(selection: $mainPicker, matching: .images) {
                    PhotoSquare(
                        data: mainPhotoData,
                        size: 120,
                        showsPlusWhenEmpty: true
                    )
                }
                .buttonStyle(.plain)
            }

            // サブ
            VStack(alignment: .leading, spacing: 10) {
                Text("サブ（最大5枚）")
                    .font(.custom("HanazonoMincho", size: 14))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // 既存サブ画像
                        ForEach(Array(subPhotos.enumerated()), id: \.offset) { idx, d in
                            ZStack(alignment: .topTrailing) {
                                PhotoSquare(
                                    data: d,
                                    size: 86,
                                    showsPlusWhenEmpty: false
                                )

                                Button {
                                    subPhotos.remove(at: idx)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(Color.black.opacity(0.35)))
                                }
                                .padding(6)
                            }
                        }

                        // 追加（小さめ＋）
                        if subPhotos.count < 5 {
                            PhotosPicker(selection: $subPicker, matching: .images) {
                                PhotoSquare(
                                    data: nil,
                                    size: 86,
                                    showsPlusWhenEmpty: true
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 16)
    }

    /// 正方形サムネ用（添付の＋タイルっぽい見た目）
    private struct PhotoSquare: View {
        let data: Data?
        let size: CGFloat
        let showsPlusWhenEmpty: Bool

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: size, height: size)

                if let data, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else if showsPlusWhenEmpty {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.8))
                }
            }
        }
    }
    
    private func loadIfExists() {
        guard let e = todayEntry else { return }
        title = e.title ?? ""
        bodyText = e.body
        mainPhotoData = e.mainPhotoData
        subPhotos = e.subPhotoDataList
    }
    
    private func compressJPEG(_ data: Data?, quality: CGFloat = 0.7) -> Data? {
        guard let data,
              let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: quality)
    }

    private func save() {
        guard DateProvider.todayKey() == todayKey else {
            errorMessage = "当日分のみ記入できます。"
            return
        }

        let cleanedBody = bodyText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        // 画像圧縮
        let compressedMain = compressJPEG(mainPhotoData, quality: 0.7)
        let limitedSubsRaw = Array(subPhotos.prefix(5))
        let compressedSubs: [Data] = limitedSubsRaw.compactMap { compressJPEG($0, quality: 0.7) }

        // ① 日記保存
        if let e = todayEntry {
            e.title = cleanedTitle
            e.body = cleanedBody
            e.mainPhotoData = compressedMain
            e.subPhotoDataList = compressedSubs
            e.updatedAt = Date()
        } else {
            let new = DiaryEntry(
                dateKey: todayKey,
                title: cleanedTitle,
                body: cleanedBody,
                mainPhotoData: compressedMain,
                subPhotoDataList: compressedSubs
            )
            modelContext.insert(new)
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "保存に失敗しました。"
            return
        }

        // ===== バッジ付与：登録→再取得→モーダル =====
        do {
            // 1) 付与前の獲得一覧を取っておく（差分計算用）
            let beforeEarned = try modelContext.fetch(FetchDescriptor<EarnedBadge>())
            let beforeSet = Set(beforeEarned.map { $0.id })

            // 2) 判定（保存直後に日記を再fetchして確実に）
            let entriesFetched = try modelContext.fetch(FetchDescriptor<DiaryEntry>())
            let newly = BadgeEngine.newlyEarned(entries: entriesFetched, alreadyEarned: beforeSet)

            // 新規が無ければ閉じる
            if newly.isEmpty {
                dismiss()
                return
            }

            // 3) DBに登録して保存
            for id in newly {
                modelContext.insert(EarnedBadge(id: id))
            }
            try modelContext.save()

            // 4) 保存後にもう一度取得して“本当に入ったもの”を確定
            let afterEarned = try modelContext.fetch(FetchDescriptor<EarnedBadge>())
            let afterSet = Set(afterEarned.map { $0.id })

            // 今回追加された分だけ（確実）
            let added = Array(afterSet.subtracting(beforeSet))

            // 5) 表示順を元の newly の順に揃える（UIが気持ちいい）
            let orderedAdded = newly.filter { added.contains($0) }

            // 6) モーダル表示（順序保証）
            self.newBadgeIds = orderedAdded
            self.showBadgeModal = true
            return

        } catch {
            // バッジ処理に失敗しても日記は保存できているので閉じる
            dismiss()
            return
        }
    }
}
