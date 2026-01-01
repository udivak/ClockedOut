import Foundation
import GRDB

final class WeeklySummaryRepository {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func save(_ summaries: [WeeklySummary], for monthId: Int64) async throws {
        try await dbQueue.write { db in
            // Delete existing weekly summaries for this month
            try WeeklySummary.filter(Column("month_id") == monthId).deleteAll(db)
            
            // Insert new summaries
            for summary in summaries {
                let summaryWithMonthId = WeeklySummary(
                    id: summary.id,
                    monthId: monthId,
                    weekStartDate: summary.weekStartDate,
                    weekEndDate: summary.weekEndDate,
                    weekdayHours: summary.weekdayHours,
                    weekendHours: summary.weekendHours,
                    createdAt: summary.createdAt
                )
                try summaryWithMonthId.save(db)
            }
        }
        Logger.log("Saved \(summaries.count) weekly summaries for month ID: \(monthId)", log: Logger.database)
    }
    
    func fetch(for monthId: Int64) async throws -> [WeeklySummary] {
        return try await dbQueue.read { db in
            try WeeklySummary
                .filter(Column("month_id") == monthId)
                .order(Column("week_start_date"))
                .fetchAll(db)
        }
    }
    
    func delete(for monthId: Int64) async throws {
        _ = try await dbQueue.write { db in
            try WeeklySummary.filter(Column("month_id") == monthId).deleteAll(db)
        }
        Logger.log("Deleted weekly summaries for month ID: \(monthId)", log: Logger.database)
    }
    
    func fetchWeekRange(start: String, end: String) async throws -> [WeeklySummary] {
        return try await dbQueue.read { db in
            try WeeklySummary
                .filter(Column("week_start_date") >= start && Column("week_end_date") <= end)
                .order(Column("week_start_date"))
                .fetchAll(db)
        }
    }
}

