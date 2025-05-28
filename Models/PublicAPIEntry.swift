
import Foundation

struct PublicAPIEntriesResponse: Codable {
    let count: Int
    let entries: [PublicAPIEntry]
}

struct PublicAPIEntry: Codable, Identifiable, Hashable {
    var id: String {
        return API + Link + (Category ?? "")
    }
    let API: String
    let Description: String
    let Auth: String
    let HTTPS: Bool
    let Cors: String
    let Link: String
    let Category: String? 
}
