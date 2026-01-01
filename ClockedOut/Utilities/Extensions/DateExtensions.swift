import Foundation

extension Date {
    /// Returns the start of the week (Sunday) for this date
    func startOfWeek(calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let startOfWeek = calendar.date(from: components) else {
            return self
        }
        return startOfWeek
    }
    
    /// Returns the end of the week (Saturday) for this date
    func endOfWeek(calendar: Calendar = .current) -> Date {
        let start = startOfWeek(calendar: calendar)
        return calendar.date(byAdding: .day, value: 6, to: start) ?? self
    }
    
    /// Returns the date range for the week containing this date
    func weekRange(calendar: Calendar = .current) -> (start: Date, end: Date) {
        let start = startOfWeek(calendar: calendar)
        let end = endOfWeek(calendar: calendar)
        return (start, end)
    }
    
    /// Formats the date as "MM/YYYY" string
    func toMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        return formatter.string(from: self)
    }
    
    /// Parses a CSV date string in format "MM/dd/yyyy, h:mm:ss a zzz"
    static func parseCSVDate(_ dateString: String) throws -> Date {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Primary format: "MM/dd/yyyy, h:mm:ss a zzz"
        let primaryFormatter = DateFormatter()
        primaryFormatter.dateFormat = "MM/dd/yyyy, h:mm:ss a zzz"
        primaryFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = primaryFormatter.date(from: trimmed) {
            return date
        }
        
        // Fallback format: "MM/dd/yyyy, h:mm:ss a" (without timezone)
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = fallbackFormatter.date(from: trimmed) {
            return date
        }
        
        // Another fallback: "MM/dd/yyyy"
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "MM/dd/yyyy"
        simpleFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = simpleFormatter.date(from: trimmed) {
            return date
        }
        
        throw ParserError.invalidDate(dateString, "Could not parse date in any supported format")
    }
    
    /// Converts IST timezone to local timezone
    static func convertISTToLocal(_ dateString: String) throws -> Date {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse with IST timezone
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, h:mm:ss a zzz"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "IST")
        
        guard let istDate = formatter.date(from: trimmed) else {
            throw ParserError.timezoneConversionFailed(dateString)
        }
        
        // Convert to local timezone
        return istDate
    }
    
    /// Flexible date parser that handles timezone abbreviations by stripping them
    static func parseCSVDateFlexible(_ dateString: String) throws -> Date {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try removing timezone suffix and parsing
        // Format: "12/01/2025, 3:45:57 PM IST" -> "12/01/2025, 3:45:57 PM"
        if let lastSpace = trimmed.lastIndex(of: " "),
           trimmed[lastSpace...].count <= 5 { // Timezone abbrev is short (IST, PST, etc.)
            let dateWithoutTZ = String(trimmed[..<lastSpace])
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Try with 1 or 2 digit month
            for format in ["M/dd/yyyy, h:mm:ss a", "MM/dd/yyyy, h:mm:ss a"] {
                formatter.dateFormat = format
                // Assume IST (India Standard Time = UTC+5:30)
                formatter.timeZone = TimeZone(secondsFromGMT: 5 * 3600 + 30 * 60)
                if let date = formatter.date(from: dateWithoutTZ) {
                    return date
                }
            }
        }
        
        // Try existing parseCSVDate as last resort
        return try parseCSVDate(trimmed)
    }
}

