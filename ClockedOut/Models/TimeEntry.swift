import Foundation

enum DayType {
    case weekday
    case weekend
}

struct TimeEntry: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let timeTrackedMs: Int64
    let timeTrackedHours: Double
    
    var dayType: DayType {
        let weekday = Calendar.current.component(.weekday, from: startDate)
        // Sunday = 1, Monday = 2, ..., Saturday = 7
        // Weekday: Sunday (1), Monday (2), Tuesday (3), Wednesday (4), Thursday (5)
        // Weekend: Friday (6), Saturday (7)
        if weekday >= 1 && weekday <= 5 {
            return .weekday
        } else {
            return .weekend
        }
    }
    
    init(id: UUID = UUID(), startDate: Date, timeTrackedMs: Int64) {
        self.id = id
        self.startDate = startDate
        self.timeTrackedMs = timeTrackedMs
        self.timeTrackedHours = Double(timeTrackedMs).toHours()
    }
    
    init?(csvRow: [String: String]) throws {
        guard let timeTrackedString = csvRow["Time Tracked"] else {
            throw ParserError.missingColumns(["Time Tracked"])
        }
        
        // Prefer Unix timestamp (milliseconds) from "Start" column
        let date: Date
        if let startTimestamp = csvRow["Start"],
           let timestampMs = Int64(startTimestamp) {
            date = Date(timeIntervalSince1970: Double(timestampMs) / 1000.0)
        } else if let startText = csvRow["Start Text"] {
            // Fallback to text parsing
            date = try Date.parseCSVDateFlexible(startText)
        } else {
            throw ParserError.missingColumns(["Start or Start Text"])
        }
        
        // Parse time tracked (milliseconds)
        guard let timeTrackedMs = Int64(timeTrackedString) else {
            throw ParserError.invalidTime(timeTrackedString)
        }
        
        self.init(startDate: date, timeTrackedMs: timeTrackedMs)
    }
}

extension TimeEntry {
    func validate() throws {
        guard timeTrackedMs >= 0 else {
            throw ValidationError.negativeValue("Time Tracked")
        }
    }
}

