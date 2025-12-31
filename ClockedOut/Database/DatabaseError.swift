import Foundation
import GRDB

enum DatabaseError: AppError {
    case migrationFailed(version: Int, error: Error)
    case queryFailed(String, Error)
    case constraintViolation(String)
    case connectionFailed(Error)
    case transactionFailed(Error)
    case recordNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .migrationFailed(let version, let error):
            return "Migration to version \(version) failed: \(error.localizedDescription)"
        case .queryFailed(let query, let error):
            return "Query failed: \(query). Error: \(error.localizedDescription)"
        case .constraintViolation(let details):
            return "Database constraint violation: \(details)"
        case .connectionFailed(let error):
            return "Database connection failed: \(error.localizedDescription)"
        case .transactionFailed(let error):
            return "Transaction failed: \(error.localizedDescription)"
        case .recordNotFound(let identifier):
            return "Record not found: \(identifier)"
        }
    }
    
    var userMessage: String {
        switch self {
        case .migrationFailed:
            return "Database update failed."
        case .queryFailed:
            return "Could not retrieve data from the database."
        case .constraintViolation:
            return "Data validation failed."
        case .connectionFailed:
            return "Could not connect to the database."
        case .transactionFailed:
            return "Database operation failed."
        case .recordNotFound:
            return "The requested record was not found."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .migrationFailed:
            return "Please try restarting the application. If the problem persists, contact support."
        case .queryFailed:
            return "Please try again. If the problem persists, the database may be corrupted."
        case .constraintViolation:
            return "Please check that all required fields are filled correctly."
        case .connectionFailed:
            return "Please try restarting the application."
        case .transactionFailed:
            return "Please try the operation again."
        case .recordNotFound:
            return "The data may have been deleted. Please refresh the view."
        }
    }
}

