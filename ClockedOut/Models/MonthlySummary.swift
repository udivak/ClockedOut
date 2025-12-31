import Foundation
import GRDB

struct MonthlySummary: Codable {
    var id: Int64?
    let month: String // Format: "MM/YYYY"
    var weekdayHours: Double
    var weekendHours: Double
    var weekdayRate: Double
    var weekendRate: Double
    var salary: Double
    var createdAt: String // ISO8601 timestamp
    var updatedAt: String // ISO8601 timestamp
    
    init(
        id: Int64? = nil,
        month: String,
        weekdayHours: Double = 0.0,
        weekendHours: Double = 0.0,
        weekdayRate: Double = 0.0,
        weekendRate: Double = 0.0,
        salary: Double = 0.0,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.month = month
        self.weekdayHours = weekdayHours.rounded(to: 2)
        self.weekendHours = weekendHours.rounded(to: 2)
        self.weekdayRate = weekdayRate
        self.weekendRate = weekendRate
        self.salary = salary.rounded(to: 2)
        
        let now = Foundation.DateFormatter.iso8601Formatter.string(from: Date())
        self.createdAt = createdAt ?? now
        self.updatedAt = updatedAt ?? now
    }
    
    var totalHours: Double {
        weekdayHours + weekendHours
    }
    
    var formattedMonth: String {
        // Convert "12/2025" to "December 2025"
        let components = month.split(separator: "/")
        guard components.count == 2,
              let monthNum = Int(components[0]),
              let year = components[1] as String? else {
            return month
        }
        
        let monthNames = ["", "January", "February", "March", "April", "May", "June",
                         "July", "August", "September", "October", "November", "December"]
        
        if monthNum >= 1 && monthNum <= 12 {
            return "\(monthNames[monthNum]) \(year)"
        }
        return month
    }
    
    mutating func recalculateSalary() {
        salary = (weekdayHours * weekdayRate) + (weekendHours * weekendRate)
        salary = salary.rounded(to: 2)
        updatedAt = Foundation.DateFormatter.iso8601Formatter.string(from: Date())
    }
    
    mutating func updateRates(weekday: Double, weekend: Double) {
        weekdayRate = weekday
        weekendRate = weekend
        recalculateSalary()
    }
}

// MARK: - GRDB Conformance
extension MonthlySummary: TableRecord {
    static let databaseTableName = "monthly_summaries"
}

extension MonthlySummary: FetchableRecord {
    init(row: Row) {
        id = row["id"]
        month = row["month"]
        weekdayHours = row["weekday_hours"]
        weekendHours = row["weekend_hours"]
        weekdayRate = row["weekday_rate"]
        weekendRate = row["weekend_rate"]
        salary = row["salary"]
        createdAt = row["created_at"]
        updatedAt = row["updated_at"]
    }
}

extension MonthlySummary: PersistableRecord {
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["month"] = month
        container["weekday_hours"] = weekdayHours
        container["weekend_hours"] = weekendHours
        container["weekday_rate"] = weekdayRate
        container["weekend_rate"] = weekendRate
        container["salary"] = salary
        container["created_at"] = createdAt
        container["updated_at"] = updatedAt
    }
}

