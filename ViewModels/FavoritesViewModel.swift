
import SwiftUI
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteAPIs: [FavoriteAPI] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let dbManager = DatabaseManager.shared

    init() {
        //maybe load favorites immediately?
        // Task {
        //     await loadFavorites()
        // }
    }

    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        do {
            favoriteAPIs = try await dbManager.fetchAllFavorites()
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func removeFavorite(_ favorite: FavoriteAPI) async {
        isLoading = true
        do {
            try await dbManager.removeFavorite(id: favorite.id)
            await loadFavorites()
        } catch {
            print("Error removing favorite \(favorite.apiName): \(error.localizedDescription)")
            errorMessage = "Could not remove favorite."
            isLoading = false
        }
    }

    func removeFavorite(at offsets: IndexSet) async {
        let idsToRemove = offsets.map { favoriteAPIs[$0].id }
        
        isLoading = true
        var operationError: Error? = nil

        for id in idsToRemove {
            do {
                try await dbManager.removeFavorite(id: id)
            } catch {
                print("Error removing favorite with ID \(id): \(error.localizedDescription)")
                operationError = error
            }
        }
        
        if let error = operationError {
            errorMessage = "Could not remove one or more favorites: \(error.localizedDescription)"
        }
        
        await loadFavorites()
    }
}
