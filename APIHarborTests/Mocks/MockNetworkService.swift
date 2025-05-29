
import Foundation
@testable import APIHarbor

class MockNetworkService: NetworkServiceProtocol {
    var mockEntriesData: [PublicAPIEntry]?
    var mockError: Error?

    // Count how many times fetchPublicAPIEntries was called
    var fetchPublicAPIEntriesCallCount = 0

    func fetchPublicAPIEntries() async throws -> [PublicAPIEntry] {
        fetchPublicAPIEntriesCallCount += 1
        if let error = mockError {
            throw error
        }
        return mockEntriesData ?? [] 
    }
}
