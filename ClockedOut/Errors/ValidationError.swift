import Foundation

enum ValidationError: AppError {
    case invalidRate(String)
    case negativeValue(String)
    case zeroValue(String)
    case outOfRange(String, min: Double, max: Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidRate(let value):
            return "Invalid rate value: \(value)"
        case .negativeValue(let field):
            return "\(field) cannot be negative"
        case .zeroValue(let field):
            return "\(field) cannot be zero"
        case .outOfRange(let field, let min, let max):
            return "\(field) must be between \(min) and \(max)"
        }
    }
    
    var userMessage: String {
        switch self {
        case .invalidRate:
            return "The hourly rate is invalid."
        case .negativeValue(let field):
            return "\(field) cannot be negative."
        case .zeroValue(let field):
            return "\(field) cannot be zero."
        case .outOfRange(let field, _, _):
            return "\(field) is out of the allowed range."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidRate:
            return "Please enter a valid number for the hourly rate."
        case .negativeValue:
            return "Please enter a positive number."
        case .zeroValue:
            return "Please enter a value greater than zero."
        case .outOfRange(_, let min, let max):
            return "Please enter a value between \(min) and \(max)."
        }
    }
}

