import Foundation

struct InputValidator {
    static func validateRate(_ rate: Double, fieldName: String = "Rate") throws {
        guard rate > 0 else {
            if rate < 0 {
                throw ValidationError.negativeValue(fieldName)
            } else {
                throw ValidationError.zeroValue(fieldName)
            }
        }
        
        // Reasonable upper limit (e.g., $10,000/hour)
        guard rate <= 10_000 else {
            throw ValidationError.outOfRange(fieldName, min: 0.01, max: 10_000)
        }
    }
    
    static func validateHours(_ hours: Double, fieldName: String = "Hours") throws {
        guard hours >= 0 else {
            throw ValidationError.negativeValue(fieldName)
        }
        
        // Reasonable upper limit (e.g., 24 hours/day * 31 days = 744 hours/month)
        guard hours <= 1000 else {
            throw ValidationError.outOfRange(fieldName, min: 0, max: 1000)
        }
    }
    
    static func validateMonthString(_ month: String) -> Bool {
        let pattern = #"^\d{2}/\d{4}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: month.utf16.count)
        return regex?.firstMatch(in: month, options: [], range: range) != nil
    }
}

