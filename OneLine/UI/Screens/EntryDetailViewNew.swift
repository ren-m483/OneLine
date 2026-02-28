import SwiftUI

struct EntryDetailViewNew: View {
    let entry: DiaryEntry
    @State private var index: Int = 0

    private var allPhotos: [Data] {
        var arr: [Data] = []
        if let m = entry.mainPhotoData { arr.append(m) }
        arr.append(contentsOf: entry.subPhotoDataList)
        return arr
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text(entry.dateKey.replacingOccurrences(of: "-", with: "/"))
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .padding(.top, 6)

                    // メイン画像 + < >
                    ZStack {
                        if !allPhotos.isEmpty, let ui = UIImage(data: allPhotos[index]) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 260)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(.tertiarySystemFill))
                                .frame(height: 260)
                                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                        }

                        HStack {
                            Button { prev() } label: { Text("<").font(.title2) }
                            .padding(.leading, 12)
                            Spacer()
                            Button { next() } label: { Text(">").font(.title2) }
                            .padding(.trailing, 12)
                        }
                        .foregroundStyle(.black.opacity(0.7))
                    }
                    .padding(.horizontal, 16)

                    // サムネ横スクロール
                    if allPhotos.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(allPhotos.indices, id: \.self) { i in
                                    if let ui = UIImage(data: allPhotos[i]) {
                                        Image(uiImage: ui)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 90, height: 72)
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(i == index ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
                                            )
                                            .onTapGesture { index = i }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // タイトル・本文
                    VStack(spacing: 10) {
                        Text(entry.title?.isEmpty == false ? (entry.title ?? "") : "タイトルなし")
                            .font(.system(size: 28, weight: .semibold, design: .serif))

                        Text(entry.body)
                            .font(.system(size: 18, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .foregroundStyle(.black.opacity(0.8))
                    }
                    .padding(18)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 30)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func next() {
        guard !allPhotos.isEmpty else { return }
        index = (index + 1) % allPhotos.count
    }

    private func prev() {
        guard !allPhotos.isEmpty else { return }
        index = (index - 1 + allPhotos.count) % allPhotos.count
    }
}
