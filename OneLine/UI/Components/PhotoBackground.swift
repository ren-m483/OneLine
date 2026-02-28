import SwiftUI

struct PhotoBackground: View {
    let data: Data?
    let fallbackAssetName: String?

    var body: some View {
        Group {
            if let data, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                    // 暗幕を弱める（暗い写真が潰れにくくなる）
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.18),
                                Color.black.opacity(0.28)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    // さらに少し白を足して「暗い写真」を持ち上げる
                    .overlay(Color.white.opacity(0.06).blendMode(.screen))
                    .blur(radius: 1.2)
            } else if let name = fallbackAssetName {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            } else {
                Color(.systemGroupedBackground).ignoresSafeArea()
            }
        }
    }
}
