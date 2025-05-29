
import Foundation

class NetworkService: NetworkServiceProtocol {
    //former method to retrieve data, this is down...
    // private let apiURL = URL(string: "https://api.publicapis.org/entries")!

    func fetchPublicAPIEntries() async throws -> [PublicAPIEntry] {
        print("NetworkService: Attempting to load from local JSON 'api_directory.json'")

        guard let url = Bundle.main.url(forResource: "api_directory", withExtension: "json") else {
            let errorDescription = "Local JSON file 'api_directory.json' not found in app bundle."
            print("NetworkService: ERROR - \(errorDescription)")
            // Throw a more descriptive error if needed by your ViewModel
            throw NSError(domain: "NetworkServiceError", code: 404, userInfo: [NSLocalizedDescriptionKey: errorDescription])
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(PublicAPIEntriesResponse.self, from: data)
            print("NetworkService: Successfully decoded \(decodedResponse.entries.count) entries from local JSON.")
            return decodedResponse.entries
        } catch {
            let errorDescription = "Failed to decode local JSON 'api_directory.json': \(error.localizedDescription)"
            print("NetworkService: ERROR - \(errorDescription)")
            // This could be due to a malformed JSON file or a mismatch
            // between your Codable structs and the JSON structure.
            throw NSError(domain: "NetworkServiceError", code: 500, userInfo: [NSLocalizedDescriptionKey: errorDescription, NSUnderlyingErrorKey: error])
        }
    }
}
