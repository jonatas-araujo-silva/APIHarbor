import Foundation

struct PublicAPIEntriesResponse: Codable {
    let count: Int
    let entries: [PublicAPIEntry]
}

struct PublicAPIEntry: Codable, Identifiable, Hashable {
    let api: String
    let descriptionText: String
    let auth: String
    let https: Bool
    let cors: String
    let link: String
    let category: String?

    var id: String {
        return api + link + (category ?? "")
    }

    enum CodingKeys: String, CodingKey {
        case api = "API"
        case descriptionText = "Description"
        case auth = "Auth"
        case https = "HTTPS" 
        case cors = "Cors"
        case link = "Link"
        case category = "Category"
    }
}
