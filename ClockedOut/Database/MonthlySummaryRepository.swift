import Foundation
import GRDB

final class MonthlySummaryRepository {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func save(_ summary: MonthlySummary) async throws {
        try await dbQueue.write { db in
            try summary.save(db)
        }
        Logger.log("Saved monthly summary for month: \(summary.month)", log: Logger.database)
    }
    
    func fetch(month: String) async throws -> MonthlySummary? {
        return try await dbQueue.read { db in
            try MonthlySummary.filter(Column("month") == month).fetchOne(db)
        }
    }
    
    func fetchAll() async throws -> [MonthlySummary] {
        return try await dbQueue.read { db in
            try MonthlySummary.order(Column("month").desc).fetchAll(db)
        }
    }
    
    func delete(month: String) async throws {
        try await dbQueue.write { db in
            if let summary = try MonthlySummary.filter(Column("month") == month).fetchOne(db) {
                try summary.delete(db)
                Logger.log("Deleted monthly summary for month: \(month)", log: Logger.database)
            }
        }
    }
    
    func exists(month: String) async throws -> Bool {
        return try await dbQueue.read { db in
            try MonthlySummary.filter(Column("month") == month).fetchCount(db) > 0
        }
    }
    
    func updateSalary(for month: String) async throws {
        try await dbQueue.write { db in
            if var summary = try MonthlySummary.filter(Column("month") == month).fetchOne(db) {
                summary.recalculateSalary()
                try summary.save(db)
            }
        }
    }
    
    func updateRates(weekday: Double, weekend: Double, for month: String) async throws {
        try await dbQueue.write { db in
            if var summary = try MonthlySummary.filter(Column("month") == month).fetchOne(db) {
                summary.updateRates(weekday: weekday, weekend: weekend)
                try summary.save(db)
            }
        }
    }
    
    func recalculateAllSalaries() async throws {
        try await dbQueue.write { db in
            let summaries = try MonthlySummary.fetchAll(db)
            for var summary in summaries {
                summary.recalculateSalary()
                try summary.save(db)
            }
        }
        Logger.log("Recalculated salaries for all monthly summaries", log: Logger.database)
    }
}

