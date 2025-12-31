import Foundation

protocol AppError: LocalizedError {
    var userMessage: String { get }
    var recoverySuggestion: String? { get }
}

extension AppError {
    var recoverySuggestion: String? {
        nil
    }
}

