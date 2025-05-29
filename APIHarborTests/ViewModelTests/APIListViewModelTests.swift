
import XCTest
@testable import APIHarbor

@MainActor
class APIListViewModelTests: XCTestCase {

    var viewModel: APIListViewModel!
    var mockNetworkService: MockNetworkService!
    var mockDbManager: MockDatabaseManager!

    let sampleEntry1 = PublicAPIEntry(API: "Cats API", Description: "Facts about cats", Auth: "", HTTPS: true, Cors: "yes", Link: "link1", Category: "Animals")
    let sampleEntry2 = PublicAPIEntry(API: "Dogs API", Description: "Facts about dogs", Auth: "apiKey", HTTPS: true, Cors: "no", Link: "link2", Category: "Animals")
    let sampleEntry3 = PublicAPIEntry(API: "Birds API", Description: "Facts about birds", Auth: "", HTTPS: false, Cors: "unknown", Link: "link3", Category: "Animals")


    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNetworkService = MockNetworkService()
        mockDbManager = MockDatabaseManager()
        viewModel = APIListViewModel(networkService: mockNetworkService,
                                     dbManager: mockDbManager,
                                     loadInitialData: false) 
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkService = nil
        mockDbManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Load Entries Tests

    func testLoadEntries_Success_PopulatesEntriesAndFavoriteIDs() async throws {
        // Arrange:
        mockNetworkService.mockEntriesData = [sampleEntry1, sampleEntry2]
        let favoriteCat = FavoriteAPI(from: sampleEntry1)
        mockDbManager.mockFavorites = [favoriteCat]
        
        viewModel.entries = []
        viewModel.favoriteIDs = []
        await viewModel.loadEntries()

        // Assert:
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after successful load")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on success")
        XCTAssertEqual(viewModel.entries.count, 2, "Should have loaded 2 entries")
        XCTAssertEqual(viewModel.entries.first?.API, "Cats API", "Entries should be sorted by API name")
        XCTAssertTrue(viewModel.favoriteIDs.contains(sampleEntry1.id), "Cats API should be a favorite")
        XCTAssertFalse(viewModel.favoriteIDs.contains(sampleEntry2.id), "Dogs API should not be a favorite")
        XCTAssertEqual(mockNetworkService.fetchPublicAPIEntriesCallCount, 1, "fetchPublicAPIEntries should be called once by this specific test call (plus init call if not managed)")
        XCTAssertEqual(mockDbManager.fetchAllFavoritesCallCount, 1, "fetchAllFavorites should be called once by this specific test call (plus init call if not managed)")
    }

    func testLoadEntries_NetworkError_SetsErrorMessageAndClearsEntries() async throws {
        // Arrange
        mockNetworkService.mockError = URLError(.notConnectedToInternet)
        viewModel.entries = [sampleEntry1]
        
        // Act
        await viewModel.loadEntries()

        // Assert
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after network error")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage should be set on network error")
        XCTAssertTrue(viewModel.entries.isEmpty, "Entries should be cleared on network error")
    }

    // MARK: - Toggle Favorite Tests

    func testToggleFavorite_AddsNewFavorite() async throws {
        // Arrange
        viewModel.entries = [sampleEntry1]
        viewModel.favoriteIDs = []
        mockDbManager.mockFavorites = []

        // Act
        await viewModel.toggleFavorite(for: sampleEntry1)

        // Assert
        XCTAssertTrue(viewModel.favoriteIDs.contains(sampleEntry1.id), "sampleEntry1 ID should now be in favoriteIDs")
        XCTAssertEqual(mockDbManager.saveFavoriteCallCount, 1, "saveFavorite should be called once")
        XCTAssertEqual(mockDbManager.lastSavedFavorite?.id, sampleEntry1.id, "Correct favorite should be saved")
        XCTAssertNil(viewModel.errorMessage, "No error message should be present")
    }

    func testToggleFavorite_RemovesExistingFavorite() async throws {
        // Arrange
        viewModel.entries = [sampleEntry1]
        viewModel.favoriteIDs = [sampleEntry1.id]
        let favoriteEntry1 = FavoriteAPI(from: sampleEntry1)
        mockDbManager.mockFavorites = [favoriteEntry1]

        // Act
        await viewModel.toggleFavorite(for: sampleEntry1)

        // Assert
        XCTAssertFalse(viewModel.favoriteIDs.contains(sampleEntry1.id), "sampleEntry1 ID should be removed from favoriteIDs")
        XCTAssertEqual(mockDbManager.removeFavoriteCallCount, 1, "removeFavorite should be called once")
        XCTAssertEqual(mockDbManager.lastRemovedFavoriteId, sampleEntry1.id, "Correct favorite ID should be removed")
        XCTAssertNil(viewModel.errorMessage, "No error message should be present")
    }
    
    func testToggleFavorite_HandlesDBErrorOnAdd() async throws {
        // Arrange
        viewModel.entries = [sampleEntry1]
        viewModel.favoriteIDs = []
        mockDbManager.mockErrorForSaveFavorite = NSError(domain: "DBTestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to save"])
        
        mockDbManager.mockFavorites = []

        // Act
        await viewModel.toggleFavorite(for: sampleEntry1)

        // Assert
        XCTAssertFalse(viewModel.favoriteIDs.contains(sampleEntry1.id), "Favorite should not be added on DB error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertEqual(mockDbManager.fetchAllFavoritesCallCount, 1, "refreshFavoriteStatus should be called on error")
    }


    // MARK: - Filtered Entries Tests

    func testFilteredEntries_WhenSearchTextIsEmpty_ReturnsAllEntries() {
        // Arrange
        viewModel.entries = [sampleEntry1, sampleEntry2]
        viewModel.searchText = ""

        // Act
        let filtered = viewModel.filteredEntries

        // Assert
        XCTAssertEqual(filtered.count, 2, "Should return all entries when searchText is empty")
    }

    func testFilteredEntries_WhenSearchTextMatchesAPI_ReturnsMatchingEntries() {
        // Arrange
        viewModel.entries = [sampleEntry1, sampleEntry2, sampleEntry3]
        viewModel.searchText = "Cats"

        // Act
        let filtered = viewModel.filteredEntries

        // Assert
        XCTAssertEqual(filtered.count, 1, "Should return one matching entry")
        XCTAssertEqual(filtered.first?.API, "Cats API")
    }
    
    func testFilteredEntries_WhenSearchTextMatchesDescription_ReturnsMatchingEntries() {
        // Arrange
        viewModel.entries = [sampleEntry1, sampleEntry2, sampleEntry3]
        viewModel.searchText = "dogs"

        // Act
        let filtered = viewModel.filteredEntries

        // Assert
        XCTAssertEqual(filtered.count, 1, "Should return one matching entry by description")
        XCTAssertEqual(filtered.first?.API, "Dogs API")
    }

    func testFilteredEntries_WhenSearchTextMatchesCategory_ReturnsMatchingEntries() {
        // Arrange
        viewModel.entries = [sampleEntry1, sampleEntry2, sampleEntry3]
        viewModel.searchText = "Animals"

        // Act
        let filtered = viewModel.filteredEntries

        // Assert
        XCTAssertEqual(filtered.count, 3, "Should return all entries matching category")
    }

    func testFilteredEntries_WhenSearchTextNoMatch_ReturnsEmpty() {
        // Arrange
        viewModel.entries = [sampleEntry1, sampleEntry2]
        viewModel.searchText = "XYZ_NO_MATCH_XYZ"

        // Act
        let filtered = viewModel.filteredEntries

        // Assert
        XCTAssertTrue(filtered.isEmpty, "Should return empty array for no match")
    }


    // MARK: - Refresh Favorite Status Tests
    func testRefreshFavoriteStatus_UpdatesFavoriteIDsSet() async throws {
        // Arrange
        let fav1 = FavoriteAPI(from: sampleEntry1)
        let fav2 = FavoriteAPI(from: sampleEntry2)
        mockDbManager.mockFavorites = [fav1, fav2]
        viewModel.favoriteIDs = [sampleEntry1.id]

        // Act
        await viewModel.refreshFavoriteStatus()

        // Assert
        XCTAssertEqual(viewModel.favoriteIDs.count, 2, "favoriteIDs count should be 2")
        XCTAssertTrue(viewModel.favoriteIDs.contains(sampleEntry1.id))
        XCTAssertTrue(viewModel.favoriteIDs.contains(sampleEntry2.id))
        XCTAssertEqual(mockDbManager.fetchAllFavoritesCallCount, 1)
    }
}

// Helper to extend MockDatabaseManager
//extension MockDatabaseManager {
//    static var errorDomain = "MockDBError"
//    var mockErrorForSaveFavorite: Error?
//    var mockErrorForRemoveFavorite: Error?
//
//    // You would modify your mock saveFavorite to throw this if set
//    // Example:
//    // override func saveFavorite(_ favorite: FavoriteAPI) async throws {
//    //     if let error = mockErrorForSaveFavorite { throw error }
//    //     saveFavoriteCallCount += 1
//    //     // ... rest of logic
//    // }
//}
