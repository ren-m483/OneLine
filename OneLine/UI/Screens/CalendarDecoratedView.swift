import SwiftUI
import SwiftData

struct CalendarDecoratedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.dateKey, order: .reverse) private var entries: [DiaryEntry]
    @Query private var settingsList: [UserSettings]

    @State private var monthCursor: Date = Date()
    @State private var selected: Date = Date()
    @State private var showDatePicker = false

    @State private var showBadges = false
    @State private var showSearch = false
    @State private var showUser = false

    private var settings: UserSettings {
        if let s = settingsList.first { return s }
        let s = UserSettings()
        modelContext.insert(s)
        return s
    }
    private var streak: Int { StreakCalculator.currentStreak(entries: entries) }

    private var titleText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/M/d"
        return f.string(from: selected)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        calendarCard
                        selectedEntryCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showUser = true } label: {
                        AvatarRingView(avatarData: settings.userAvatarData, tier: Tier.from(streak: streak))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button { showBadges = true } label: { Image(systemName: "rosette") }
                        Button { showSearch = true } label: { Image(systemName: "magnifyingglass") }
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selected: $selected, monthCursor: $monthCursor)
            }
            .sheet(isPresented: $showBadges) { BadgesViewNew() }
            .sheet(isPresented: $showSearch) { SearchView() }
            .sheet(isPresented: $showUser) { UserProfileView() }
            .onAppear {
                resetToToday()
            }
            .onReceive(NotificationCenter.default.publisher(for: .calendarTabSelected)) { _ in
                resetToToday()
            }
        }
    }

    private var header: some View {
        HStack {
            Button { shiftMonth(-1) } label: { Image(systemName: "chevron.left") }
            Spacer()
            Button { showDatePicker = true } label: {
                Text(titleText)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(.black.opacity(0.85))
            }
            Spacer()
            Button { shiftMonth(1) } label: { Image(systemName: "chevron.right") }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
    }

    private var calendarCard: some View {
        let days = MonthGrid.make(for: monthCursor)
        let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

        return VStack(spacing: 12) {
            HStack {
                ForEach(["日","月","火","水","木","金","土"], id: \.self) { w in
                    Text(w)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(w == "日" ? .red : (w == "土" ? .blue : .secondary))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(days, id: \.self) { d in
                    let inMonth = Calendar.current.isDate(d, equalTo: monthCursor, toGranularity: .month)
                    DayCellNew(
                        date: d,
                        inMonth: inMonth,
                        thumb: entry(for: d)?.mainPhotoData,
                        isSelected: Calendar.current.isDate(d, inSameDayAs: selected),
                        onTap: { selected = d }
                    )
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
    }

    private var selectedEntryCard: some View {
        let e = entry(for: selected)
        return Group {
            if let e, (e.mainPhotoData != nil || !(e.title ?? "").isEmpty || !e.body.isEmpty) {
                NavigationLink {
                    EntryDetailViewNew(entry: e)
                } label: {
                    HStack(spacing: 12) {
                        if let d = e.mainPhotoData, let ui = UIImage(data: d) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 92, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text((e.title?.isEmpty == false) ? (e.title ?? "") : "タイトルなし")
                                .font(.headline)

                            Text(e.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func entry(for date: Date) -> DiaryEntry? {
        let key = DateProvider.key(for: date)
        return entries.first(where: { $0.dateKey == key })
    }
    
    private func resetToToday() {
        let cal = Calendar.current
        let today = Date()
        selected = today
        monthCursor = cal.date(from: cal.dateComponents([.year, .month], from: today)) ?? today
    }

    private func shiftMonth(_ delta: Int) {
        let cal = Calendar.current

        // カレンダー表示（月）を動かす
        monthCursor = cal.date(byAdding: .month, value: delta, to: monthCursor) ?? monthCursor

        // 選択中の日付も “1ヶ月前/後” にする（年・日を維持しようとして、無理ならその月末）
        let year = cal.component(.year, from: selected)
        let day = cal.component(.day, from: selected)
        let newMonth = cal.component(.month, from: monthCursor)

        var comps = DateComponents()
        comps.year = year
        comps.month = newMonth
        comps.day = day

        if let candidate = cal.date(from: comps) {
            selected = candidate
        } else {
            // 例：3/31 → 2月には無いので月末に寄せる
            comps.day = min(day, cal.range(of: .day, in: .month, for: cal.date(from: DateComponents(year: year, month: newMonth, day: 1))!)!.count)
            selected = cal.date(from: comps) ?? selected
        }
    }
}

private struct DayCellNew: View {
    let date: Date
    let inMonth: Bool
    let thumb: Data?
    let isSelected: Bool
    let onTap: () -> Void

    var day: Int { Calendar.current.component(.day, from: date) }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(day)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(inMonth ? .primary : .secondary)

                if let thumb, let ui = UIImage(data: thumb) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                } else {
                    Circle().fill(Color.clear).frame(width: 26, height: 26)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.14) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .opacity(inMonth ? 1.0 : 0.35)
    }
}

private struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: Date
    @Binding var monthCursor: Date

    @State private var y: Int = 2026
    @State private var m: Int = 1
    @State private var d: Int = 1

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                Picker("年", selection: $y) {
                    ForEach(2010...2035, id: \.self) { Text("\($0)年").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("月", selection: $m) {
                    ForEach(1...12, id: \.self) { Text("\($0)月").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("日", selection: $d) {
                    ForEach(1...daysInMonth(year: y, month: m), id: \.self) { Text("\($0)日").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                let cal = Calendar.current
                y = cal.component(.year, from: selected)
                m = cal.component(.month, from: selected)
                d = cal.component(.day, from: selected)
            }
            .navigationTitle("日付を選択")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        var comps = DateComponents()
                        comps.year = y
                        comps.month = m
                        comps.day = min(d, daysInMonth(year: y, month: m))

                        let cal = Calendar.current
                        if let newDate = cal.date(from: comps) {
                            selected = newDate
                            monthCursor = cal.date(from: cal.dateComponents([.year, .month], from: newDate)) ?? monthCursor
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private func daysInMonth(year: Int, month: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        let cal = Calendar.current
        let date = cal.date(from: comps) ?? Date()
        return cal.range(of: .day, in: .month, for: date)?.count ?? 30
    }
}

enum MonthGrid {
    static func make(for month: Date) -> [Date] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let range = cal.range(of: .day, in: .month, for: start)!
        let firstWeekday = cal.component(.weekday, from: start)

        let prefix = firstWeekday - 1
        var days: [Date] = []
        for i in 0..<prefix {
            days.append(cal.date(byAdding: .day, value: -(prefix - i), to: start)!)
        }
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: start)!)
        }
        while days.count < 42 {
            days.append(cal.date(byAdding: .day, value: 1, to: days.last!)!)
        }
        return days
    }
}
