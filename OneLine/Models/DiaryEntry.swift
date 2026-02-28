import Foundation
import SwiftData

@Model
final class DiaryEntry {
    @Attribute(.unique) var dateKey: String

    var title: String?
    var body: String

    @Attribute(.externalStorage) var mainPhotoData: Data?

    // 永続化は Data 1本にする（SwiftDataが安定）
    @Attribute(.externalStorage) private var subPhotoDataBlob: Data?

    var createdAt: Date
    var updatedAt: Date

    // アプリ側はこれを使う（名前はそのまま維持）
    var subPhotoDataList: [Data] {
        get {
            guard let subPhotoDataBlob else { return [] }
            return (try? PropertyListDecoder().decode([Data].self, from: subPhotoDataBlob)) ?? []
        }
        set {
            subPhotoDataBlob = try? PropertyListEncoder().encode(newValue)
        }
    }

    init(
        dateKey: String,
        title: String?,
        body: String,
        mainPhotoData: Data?,
        subPhotoDataList: [Data] = []
    ) {
        self.dateKey = dateKey
        self.title = title
        self.body = body
        self.mainPhotoData = mainPhotoData
        self.subPhotoDataBlob = try? PropertyListEncoder().encode(subPhotoDataList)
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
