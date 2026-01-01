import Foundation

extension Double {
    /// Converts milliseconds to hours
    func toHours() -> Double {
        return self / 3_600_000.0
    }
    
    /// Rounds to specified decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Formats as "X h Y m" string
    func formatAsHours() -> String {
        let totalHours = self
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        
        if hours > 0 && minutes > 0 {
            return "\(hours) h \(minutes) m"
        } else if hours > 0 {
            return "\(hours) h"
        } else if minutes > 0 {
            return "\(minutes) m"
        } else {
            return "0 h"
        }
    }
    
    /// Formats as decimal hours (e.g., "27.5")
    func formatAsDecimalHours() -> String {
        return String(format: "%.2f", self.rounded(to: 2))
    }
    
    /// Formats as clean decimal, removing trailing zeros (e.g., 15.0 → "15", 9.83 → "9.83")
    func formatClean() -> String {
        let rounded = self.rounded(to: 2)
        if rounded == rounded.rounded() {
            return String(format: "%.0f", rounded)
        } else if rounded * 10 == (rounded * 10).rounded() {
            return String(format: "%.1f", rounded)
        } else {
            return String(format: "%.2f", rounded)
        }
    }
}

