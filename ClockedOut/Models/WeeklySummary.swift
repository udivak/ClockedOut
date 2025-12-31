import Foundation
import GRDB

struct WeeklySummary: Codable {
    var id: Int64?
    let monthId: Int64
    let weekStartDate: String // ISO8601 date
    let weekEndDate: String // ISO8601 date
    var weekdayHours: Double
    var weekendHours: Double
    var createdAt: String // ISO8601 timestamp
    
    init(
        id: Int64? = nil,
        monthId: Int64,
        weekStartDate: String,
        weekEndDate: String,
        weekdayHours: Double = 0.0,
        weekendHours: Double = 0.0,
        createdAt: String? = nil
    ) {
        self.id = id
        self.monthId = monthId
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.weekdayHours = weekdayHours.rounded(to: 2)
        self.weekendHours = weekendHours.rounded(to: 2)
        
        let now = Foundation.DateFormatter.iso8601Formatter.string(from: Date())
        self.createdAt = createdAt ?? now
    }
    
    var totalHours: Double {
        weekdayHours + weekendHours
    }
    
    func toWeeklyReport() -> WeeklyReport? {
        let formatter = Foundation.DateFormatter.iso8601Formatter
        guard let startDate = formatter.date(from: weekStartDate),
              let endDate = formatter.date(from: weekEndDate) else {
            return nil
        }
        
        return WeeklyReport(
            weekStartDate: startDate,
            weekEndDate: endDate,
            weekdayHours: weekdayHours,
            weekendHours: weekendHours
        )
    }
}

// MARK: - GRDB Conformance
extension WeeklySummary: TableRecord {
    static let databaseTableName = "weekly_summaries"
}

extension WeeklySummary: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        monthId = row["month_id"]
        weekStartDate = row["week_start_date"]
        weekEndDate = row["week_end_date"]
        weekdayHours = row["weekday_hours"]
        weekendHours = row["weekend_hours"]
        createdAt = row["created_at"]
    }
}

extension WeeklySummary: PersistableRecord {
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["month_id"] = monthId
        container["week_start_date"] = weekStartDate
        container["week_end_date"] = weekEndDate
        container["weekday_hours"] = weekdayHours
        container["weekend_hours"] = weekendHours
        container["created_at"] = createdAt
    }
}

