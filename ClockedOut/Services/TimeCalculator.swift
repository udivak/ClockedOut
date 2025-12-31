import Foundation

final class TimeCalculator {
    static let shared = TimeCalculator()
    
    private init() {}
    
    enum DayType {
        case weekday
        case weekend
    }
    
    func classifyDayOfWeek(_ date: Date) -> DayType {
        let weekday = Calendar.current.component(.weekday, from: date)
        // Sunday = 1, Monday = 2, ..., Saturday = 7
        // Weekday: Sunday (1), Monday (2), Tuesday (3), Wednesday (4), Thursday (5)
        // Weekend: Friday (6), Saturday (7)
        if weekday >= 1 && weekday <= 5 {
            return .weekday
        } else {
            return .weekend
        }
    }
    
    func groupByWeek(_ entries: [TimeEntry]) -> [WeekRange: [TimeEntry]] {
        var grouped: [WeekRange: [TimeEntry]] = [:]
        
        for entry in entries {
            let range = WeekRange(startDate: entry.startDate, endDate: entry.startDate)
            if grouped[range] == nil {
                grouped[range] = []
            }
            grouped[range]?.append(entry)
        }
        
        return grouped
    }
    
    func calculateWeeklyHours(_ entries: [TimeEntry]) -> WeeklyReport {
        guard let firstEntry = entries.first else {
            let date = Date()
            return WeeklyReport(
                weekStartDate: date.startOfWeek(),
                weekEndDate: date.endOfWeek(),
                weekdayHours: 0,
                weekendHours: 0
            )
        }
        
        let weekStart = firstEntry.startDate.startOfWeek()
        let weekEnd = firstEntry.startDate.endOfWeek()
        
        var weekdayHours: Double = 0
        var weekendHours: Double = 0
        
        for entry in entries {
            switch classifyDayOfWeek(entry.startDate) {
            case .weekday:
                weekdayHours += entry.timeTrackedHours
            case .weekend:
                weekendHours += entry.timeTrackedHours
            }
        }
        
        return WeeklyReport(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            weekdayHours: weekdayHours,
            weekendHours: weekendHours
        )
    }
    
    func calculateMonthlyTotals(_ entries: [TimeEntry]) -> (weekdayHours: Double, weekendHours: Double) {
        var weekdayHours: Double = 0
        var weekendHours: Double = 0
        
        for entry in entries {
            switch classifyDayOfWeek(entry.startDate) {
            case .weekday:
                weekdayHours += entry.timeTrackedHours
            case .weekend:
                weekendHours += entry.timeTrackedHours
            }
        }
        
        return (
            weekdayHours: weekdayHours.rounded(to: 2),
            weekendHours: weekendHours.rounded(to: 2)
        )
    }
    
    func determineMonth(from entries: [TimeEntry]) -> String? {
        guard let firstEntry = entries.first else {
            return nil
        }
        
        return firstEntry.startDate.toMonthString()
    }
    
    func generateWeeklyReports(from entries: [TimeEntry]) -> [WeeklyReport] {
        let grouped = groupByWeek(entries)
        var reports: [WeeklyReport] = []
        
        for (_, weekEntries) in grouped {
            let report = calculateWeeklyHours(weekEntries)
            reports.append(report)
        }
        
        // Sort by week start date
        reports.sort { $0.weekStartDate < $1.weekStartDate }
        
        return reports
    }
}

