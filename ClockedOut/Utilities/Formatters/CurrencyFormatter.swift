import Foundation

struct CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let formatter: NumberFormatter
    
    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
    }
    
    /// Formats a Double as currency
    func format(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Formats a Double as currency without symbol (for input fields)
    func formatPlain(_ amount: Double) -> String {
        let plainFormatter = NumberFormatter()
        plainFormatter.numberStyle = .decimal
        plainFormatter.minimumFractionDigits = 2
        plainFormatter.maximumFractionDigits = 2
        return plainFormatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
}

