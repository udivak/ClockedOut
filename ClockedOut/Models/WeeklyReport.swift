import Foundation

struct WeeklyReport: Identifiable, Hashable {
    let id: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    let weekdayHours: Double
    let weekendHours: Double
    
    var weekRangeString: String {
        let startDay = Calendar.current.component(.day, from: weekStartDate)
        let endDay = Calendar.current.component(.day, from: weekEndDate)
        let month = Calendar.current.component(.month, from: weekStartDate)
        return "\(startDay)-\(endDay)/\(month)"
    }
    
    var weekRangeDisplayString: String {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "MMMM d"
        let startString = formatter.string(from: weekStartDate)
        formatter.dateFormat = "d"
        let endString = formatter.string(from: weekEndDate)
        return "\(startString) - \(endString)"
    }
    
    var totalHours: Double {
        weekdayHours + weekendHours
    }
    
    init(id: UUID = UUID(), weekStartDate: Date, weekEndDate: Date, weekdayHours: Double, weekendHours: Double) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.weekdayHours = weekdayHours.rounded(to: 2)
        self.weekendHours = weekendHours.rounded(to: 2)
    }
}

struct WeekRange: Hashable {
    let startDate: Date
    let endDate: Date
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate.startOfWeek()
        self.endDate = startDate.endOfWeek()
    }
}

