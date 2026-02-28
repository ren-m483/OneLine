import SwiftUI

struct BadgeCongratsModalNew: View {
    @Environment(\.dismiss) private var dismiss
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.18))
                        .frame(width: 74, height: 74)
                    Image(systemName: "rosette")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color.orange)
                }
                .padding(.top, 8)

                Text("おめでとう！")
                    .font(.custom("HanazonoMincho", size: 26))

                Text("新しいバッジを獲得しました")
                    .font(.custom("HanazonoMincho", size: 16))
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                    onClose()
                } label: {
                    Text("閉じる")
                        .font(.custom("HanazonoMincho", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.green.opacity(0.55), Color.blue.opacity(0.55)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.top, 10)
            }
            .padding(18)
            .navigationTitle("")
        }
        .presentationBackground(.white)
        .presentationDetents([.height(320), .height(380)])
        .presentationDragIndicator(.hidden)
    }
}
