
import Foundation
@testable import APIHarbor

class MockDatabaseManager: DatabaseManagerProtocol {
    var mockFavorites: [FavoriteAPI] = []
    var mockIsFavoriteResult: Bool = false
    var lastSavedFavorite: FavoriteAPI?
    var lastRemovedFavoriteId: String?

    var saveFavoriteCallCount = 0
    var removeFavoriteCallCount = 0
    var fetchAllFavoritesCallCount = 0
    var isFavoriteCallCount = 0

    var mockErrorForSaveFavorite: Error?
    var mockErrorForRemoveFavorite: Error?
    var mockErrorForFetchAllFavorites: Error?
    var mockErrorForIsFavorite: Error?

    func saveFavorite(_ favorite: FavoriteAPI) async throws {
        if let error = mockErrorForSaveFavorite {
            throw error
        }
        saveFavoriteCallCount += 1
        lastSavedFavorite = favorite
        if let index = mockFavorites.firstIndex(where: { $0.id == favorite.id }) {
            mockFavorites[index] = favorite
        } else {
            mockFavorites.append(favorite)
        }
    }

    func removeFavorite(id: String) async throws {
        if let error = mockErrorForRemoveFavorite {
            throw error
        }
        removeFavoriteCallCount += 1
        lastRemovedFavoriteId = id
        mockFavorites.removeAll(where: { $0.id == id })
    }

    func fetchAllFavorites() async throws -> [FavoriteAPI] {
        if let error = mockErrorForFetchAllFavorites {
            throw error
        }
        fetchAllFavoritesCallCount += 1
        return mockFavorites
    }

    func isFavorite(id: String) async throws -> Bool {
        if let error = mockErrorForIsFavorite { 
            throw error
        }
        isFavoriteCallCount += 1
        return mockFavorites.contains(where: { $0.id == id })
    }
}
