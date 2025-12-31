import Foundation

struct TimeFormatter {
    static let shared = TimeFormatter()
    
    private init() {}
    
    /// Formats hours as "X h Y m"
    func formatHours(_ hours: Double) -> String {
        return hours.formatAsHours()
    }
    
    /// Formats hours as decimal (e.g., "27.5")
    func formatDecimalHours(_ hours: Double) -> String {
        return hours.formatAsDecimalHours()
    }
    
    /// Formats hours with minutes component
    func formatHoursWithMinutes(_ hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        
        if h > 0 && m > 0 {
            return "\(h)h \(m)m"
        } else if h > 0 {
            return "\(h)h"
        } else {
            return "\(m)m"
        }
    }
}

