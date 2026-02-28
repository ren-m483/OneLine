import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]

    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            List {
                let results = filtered()
                if results.isEmpty {
                    EmptyStateView(
                        title: "検索結果なし",
                        message: "",
                        actionTitle: nil,
                        action: nil
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(results) { e in
                        NavigationLink {
                            EntryDetailViewNew(entry: e)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(e.dateKey).font(.caption).foregroundStyle(.secondary)
                                if let t = e.title, !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text(t).font(.subheadline).bold()
                                }
                                Text(e.body).font(.subheadline).lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("検索")
            .searchable(text: $query, prompt: "")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func filtered() -> [DiaryEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return entries }
        return entries.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(q) ||
            $0.body.localizedCaseInsensitiveContains(q)
        }
    }
}
