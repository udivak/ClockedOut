import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var dbQueue: DatabaseQueue?
    
    private init() {}
    
    func initialize() throws {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbDirectory = appSupportURL.appendingPathComponent("ClockedOut", isDirectory: true)
        
        // Create directory if it doesn't exist
        try fileManager.createDirectory(at: dbDirectory, withIntermediateDirectories: true)
        
        let dbURL = dbDirectory.appendingPathComponent("clockedout.db")
        
        Logger.log("Initializing database at: \(dbURL.path)", log: Logger.database)
        
        var config = Configuration()
        config.prepareDatabase { db in
            // Enable foreign keys
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        
        dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)
        
        try migrate()
    }
    
    private func migrate() throws {
        guard let dbQueue = dbQueue else {
            throw DatabaseError.connectionFailed(NSError(domain: "DatabaseManager", code: -1))
        }
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("001_InitialSchema") { db in
            try Migration001_InitialSchema.migrate(db)
        }
        
        migrator.registerMigration("002_AddIndexes") { db in
            try Migration002_AddIndexes.migrate(db)
        }
        
        do {
            try migrator.migrate(dbQueue)
            Logger.log("Database migrations completed successfully", log: Logger.database)
        } catch {
            Logger.error("Database migration failed", error: error, log: Logger.database)
            // Get the count of applied migrations by reading from the database
            let appliedCount = try dbQueue.read { db in
                try migrator.appliedMigrations(db).count
            }
            throw DatabaseError.migrationFailed(version: appliedCount + 1, error: error)
        }
    }
    
    func getDatabaseQueue() throws -> DatabaseQueue {
        guard let dbQueue = dbQueue else {
            throw DatabaseError.connectionFailed(NSError(domain: "DatabaseManager", code: -1))
        }
        return dbQueue
    }
    
    func backup(to url: URL) throws {
        guard let dbQueue = dbQueue else {
            throw DatabaseError.connectionFailed(NSError(domain: "DatabaseManager", code: -1))
        }
        
        let backupQueue = try DatabaseQueue(path: url.path)
        try dbQueue.backup(to: backupQueue)
    }
}

