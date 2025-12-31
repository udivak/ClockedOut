import Foundation

final class ReportGenerator {
    static let shared = ReportGenerator()
    
    private init() {}
    
    func generateWeeklyBreakdown(from entries: [TimeEntry]) -> [WeeklyReport] {
        return TimeCalculator.shared.generateWeeklyReports(from: entries)
    }
    
    func formatWeekRange(start: Date, end: Date) -> String {
        let startDay = Calendar.current.component(.day, from: start)
        let endDay = Calendar.current.component(.day, from: end)
        let month = Calendar.current.component(.month, from: start)
        return "\(startDay)-\(endDay)/\(month)"
    }
    
    func formatHours(_ hours: Double) -> String {
        return hours.formatAsDecimalHours()
    }
    
    struct MonthlyReport {
        let summary: MonthlySummary
        let weeklyReports: [WeeklyReport]
        let totals: Totals
    }
    
    struct Totals {
        let weekdayHours: Double
        let weekendHours: Double
        let totalHours: Double
        let salary: Double
        
        init(weekdayHours: Double, weekendHours: Double, salary: Double) {
            self.weekdayHours = weekdayHours.rounded(to: 2)
            self.weekendHours = weekendHours.rounded(to: 2)
            self.totalHours = (weekdayHours + weekendHours).rounded(to: 2)
            self.salary = salary.rounded(to: 2)
        }
    }
    
    func generateMonthlyReport(summary: MonthlySummary, weeklyReports: [WeeklyReport]) -> MonthlyReport {
        let totals = Totals(
            weekdayHours: summary.weekdayHours,
            weekendHours: summary.weekendHours,
            salary: summary.salary
        )
        
        return MonthlyReport(
            summary: summary,
            weeklyReports: weeklyReports,
            totals: totals
        )
    }
}

