import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 14) {
                // ここをロゴ画像に差し替え可能（後述）
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white)
                        .frame(width: 108, height: 108)
                        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)

                    Image(systemName: "note.text")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.8))
                }

                Text("1行日記")
                    .font(.system(size: 22, weight: .bold))

                Text("今日の1行を、未来の自分へ。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
