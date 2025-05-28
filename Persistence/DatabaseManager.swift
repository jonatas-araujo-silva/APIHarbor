
import Foundation
import GRDB
import UIKit

class DatabaseManager {
    // MARK: - Properties

    // singleton pattern:
    static let shared = DatabaseManager()

    //GRDB database queue for database access:
    private var dbQueue: DatabaseQueue

    // MARK: - Init's

    private init() {
        do {
            // Define the path to the SQLite database file.
            //places the database in the Application Support directory.
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
            let dbURL = appSupportURL.appendingPathComponent("apiharbor.sqlite")
            print("Database Path: \(dbURL.path)")

            //Initialize the DatabaseQueue:
            dbQueue = try DatabaseQueue(path: dbURL.path)

            // Setup the database:
            try setupDatabaseSchemaIfNeeded()
        } catch {
            //Needs to handle with errors later...
            fatalError("Failed to initialize database: \(error.localizedDescription)")
        }
    }

    // MARK: - Database Schema Setup

    private func setupDatabaseSchemaIfNeeded() throws {
        try dbQueue.write { db in
            // Create the 'favoriteAPI' table
            try db.create(table: FavoriteAPI.databaseTableName, ifNotExists: true) { tableDefinition in
                // 'id' is the primary key, taken from the API entry.
                tableDefinition.column("id", .text).primaryKey()
                tableDefinition.column("apiName", .text).notNull()
                tableDefinition.column("descriptionText", .text).notNull()
                tableDefinition.column("link", .text).notNull()
                tableDefinition.column("category", .text) // Optional, so nullable
                tableDefinition.column("dateFavorited", .datetime).notNull()
            }
        }
        print("Database schema setup complete for \(FavoriteAPI.databaseTableName).")
    }

    // MARK: - CRUD Method FavoriteAPI

    /// This acts as an "upsert": it inserts if the ID doesn't exist, or updates if it does
    /// - Parameter favorite: The `FavoriteAPI` record to save:
    func saveFavorite(_ favorite: FavoriteAPI) async throws {
        try await dbQueue.write { db in
            // The save() method performs an INSERT or UPDATE as appropriate.
            try favorite.save(db)
            print("Saved/Updated favorite: \(favorite.apiName) (ID: \(favorite.id))")
        }
    }

    ///removes a favorite API from the database using its unique ID
    /// - Parameter id: The ID string of the favorite API to remove:
    func removeFavorite(id: String) async throws {
        let deleted: Bool = try await dbQueue.write { db in
            // deleteOne returns true if a row was deleted.
            try FavoriteAPI.deleteOne(db, key: id)
        }
        if deleted {
            print("Removed favorite with ID: \(id)")
        } else {
            print("No favorite found with ID: \(id) to remove.")
            // Optionally throw an error if deletion was expected but nothing was deleted
            //add throw AppError.databaseRecordNotFound here...
        }
    }

    /// Fetches all favorite APIs from the database
    /// - Returns: An array of `FavoriteAPI` records, ordered by date favorited (newest first):
    func fetchAllFavorites() async throws -> [FavoriteAPI] {
        try await dbQueue.read { db in
            // Order by dateFavorited in descending order (newest first).
            try FavoriteAPI.order(Column("dateFavorited").desc).fetchAll(db)
        }
    }

    /// Checks if an API with a specific ID is already marked as a favorite
    /// - Parameter id: The ID string of the API to check
    /// - Returns: `true` if the API is a favorite, `false` otherwise:
    func isFavorite(id: String) async throws -> Bool {
        try await dbQueue.read { db in
            //fetchOne returns the record if found, or nil
            //so, if it's not nil, the record exists and is a favorite
            try FavoriteAPI.fetchOne(db, key: id) != nil
        }
    }
    
    // MARK: - Optional: Helper for Deleting All Favorites (e.g., for testing or reset)
    /*
    func deleteAllFavorites() async throws {
        try await dbQueue.write { db in
            _ = try FavoriteAPI.deleteAll(db)
            print("All favorites have been deleted.")
        }
    }
    */
}

// Example AppError for database operations (optional)
/*
enum AppError: LocalizedError {
    case databaseRecordNotFound
    // Add other error cases as needed

    var errorDescription: String? {
        switch self {
        case .databaseRecordNotFound:
            return "The requested record was not found in the database."
        }
    }
}
*/
