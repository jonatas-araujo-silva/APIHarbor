
import Foundation
import GRDB

struct FavoriteAPI: Equatable, Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: String
    var apiName: String
    var descriptionText: String
    var link: String
    var category: String?
    var dateFavorited: Date

    static var databaseTableName = "favoriteAPI"

    init(from entry: PublicAPIEntry, dateFavorited: Date = Date()) {
        self.id = entry.id
        self.apiName = entry.api
        self.descriptionText = entry.descriptionText
        self.link = entry.link
        self.category = entry.category
        self.dateFavorited = dateFavorited
    }

    init(id: String, apiName: String, descriptionText: String, link: String, category: String?, dateFavorited: Date) {
        self.id = id
        self.apiName = apiName
        self.descriptionText = descriptionText
        self.link = link
        self.category = category
        self.dateFavorited = dateFavorited
    }
}

