
import Foundation

protocol NetworkServiceProtocol {
    func fetchPublicAPIEntries() async throws -> [PublicAPIEntry]
}

protocol DatabaseManagerProtocol {
    func saveFavorite(_ favorite: FavoriteAPI) async throws
    func removeFavorite(id: String) async throws
    func fetchAllFavorites() async throws -> [FavoriteAPI]
    func isFavorite(id: String) async throws -> Bool
}
