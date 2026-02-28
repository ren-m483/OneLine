import SwiftUI

struct LockGateView<Content: View>: View {
    @Binding var isUnlocked: Bool
    let content: () -> Content

    @State private var error: String?

    var body: some View {
        Group {
            if isUnlocked {
                content()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "lock.fill").font(.system(size: 36))
                    Text("ロック中").font(.title3).bold()
                    if let error {
                        Text(error).font(.caption).foregroundStyle(.secondary)
                    }
                    Button("Face IDで解除") {
                        Task { await unlock() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task { await unlock() }
                }
            }
        }
    }

    private func unlock() async {
        let ok = await BiometricLockService.evaluate(reason: "日記を表示するために認証が必要です。")
        await MainActor.run {
            if ok {
                isUnlocked = true
                error = nil
            } else {
                error = "認証に失敗しました。"
            }
        }
    }
}
