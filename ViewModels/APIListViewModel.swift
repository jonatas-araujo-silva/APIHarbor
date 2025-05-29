
import SwiftUI
import Combine

@MainActor
class APIListViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var entries: [PublicAPIEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var favoriteIDs: Set<String> = []

    var filteredEntries: [PublicAPIEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.API.localizedCaseInsensitiveContains(searchText) ||
                entry.Description.localizedCaseInsensitiveContains(searchText) ||
                (entry.Category ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private let networkService: NetworkServiceProtocol
    private let dbManager: DatabaseManagerProtocol

    init(networkService: NetworkServiceProtocol = NetworkService(),
         dbManager: DatabaseManagerProtocol = DatabaseManager.shared,
         loadInitialData: Bool = true) {
        self.networkService = networkService
        self.dbManager = dbManager
        if loadInitialData { 
            Task {
                await loadEntries()
            }
        }
    }

    func loadEntries(isRefresh: Bool = false) async {
        if !isRefresh && entries.isEmpty {
             isLoading = true
            do { isLoading = false }
        }

        errorMessage = nil
        print("APIListViewModel: Loading entries (isRefresh: \(isRefresh))...")

        do {
            let fetchedEntries = try await networkService.fetchPublicAPIEntries()
            self.entries = fetchedEntries.sorted(by: { $0.API.lowercased() < $1.API.lowercased() })
            print("APIListViewModel: Successfully fetched \(self.entries.count) entries.")
            await refreshFavoriteStatus()
        } catch {
            print("APIListViewModel: Error loading entries - \(error.localizedDescription)")
            self.errorMessage = "Failed to load API entries: \(error.localizedDescription)"
            self.entries = []
        }
        print("APIListViewModel: Loading finished.")
    }

    func toggleFavorite(for entry: PublicAPIEntry) async {
        let isCurrentlyFavorite = favoriteIDs.contains(entry.id)
        print("APIListViewModel: Toggling favorite for '\(entry.API)'. Currently favorite: \(isCurrentlyFavorite)")

        do {
            if isCurrentlyFavorite {
                try await dbManager.removeFavorite(id: entry.id)
                favoriteIDs.remove(entry.id)
                print("APIListViewModel: Unfavorited '\(entry.API)'.")
            } else {
                let favorite = FavoriteAPI(from: entry)
                try await dbManager.saveFavorite(favorite)
                favoriteIDs.insert(entry.id)
                print("APIListViewModel: Favorited '\(entry.API)'.")
            }
        } catch {
            print("APIListViewModel: Error toggling favorite for \(entry.API) - \(error.localizedDescription)")
            self.errorMessage = "Could not update favorite status for \(entry.API)."
            await refreshFavoriteStatus()
        }
    }

    func refreshFavoriteStatus() async {
        print("APIListViewModel: Refreshing favorite statuses...")
        do {
            let favoritesFromDB = try await dbManager.fetchAllFavorites()
            favoriteIDs = Set(favoritesFromDB.map { $0.id })
            print("APIListViewModel: Favorite statuses refreshed. Count: \(favoriteIDs.count)")
        } catch {
            print("APIListViewModel: Error refreshing favorite statuses - \(error.localizedDescription)")
            self.errorMessage = "Could not refresh favorite statuses."
        }
    }
}
