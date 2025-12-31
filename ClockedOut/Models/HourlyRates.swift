import Foundation

struct HourlyRates: Codable, Equatable {
    var weekdayRate: Double
    var weekendRate: Double
    
    init(weekdayRate: Double = 0.0, weekendRate: Double = 0.0) {
        self.weekdayRate = weekdayRate
        self.weekendRate = weekendRate
    }
    
    func validate() throws {
        try InputValidator.validateRate(weekdayRate, fieldName: "Weekday Rate")
        try InputValidator.validateRate(weekendRate, fieldName: "Weekend Rate")
    }
    
    func calculateSalary(weekdayHours: Double, weekendHours: Double) -> Double {
        return (weekdayHours * weekdayRate) + (weekendHours * weekendRate)
    }
}

