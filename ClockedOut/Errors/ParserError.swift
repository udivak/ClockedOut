import Foundation

enum ParserError: AppError {
    case invalidFormat(String)
    case missingColumns([String])
    case invalidDate(String, String)
    case invalidTime(String)
    case emptyFile
    case fileReadError(Error)
    case timezoneConversionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat(let details):
            return "Invalid CSV format: \(details)"
        case .missingColumns(let columns):
            return "Missing required columns: \(columns.joined(separator: ", "))"
        case .invalidDate(let dateString, let details):
            return "Invalid date format: \(dateString). \(details)"
        case .invalidTime(let timeString):
            return "Invalid time value: \(timeString)"
        case .emptyFile:
            return "The CSV file is empty"
        case .fileReadError(let error):
            return "Failed to read file: \(error.localizedDescription)"
        case .timezoneConversionFailed(let dateString):
            return "Failed to convert timezone for date: \(dateString)"
        }
    }
    
    var userMessage: String {
        switch self {
        case .invalidFormat:
            return "The CSV file format is invalid."
        case .missingColumns:
            return "The CSV file is missing required columns."
        case .invalidDate:
            return "Some dates in the CSV file could not be parsed."
        case .invalidTime:
            return "Some time values in the CSV file are invalid."
        case .emptyFile:
            return "The CSV file is empty."
        case .fileReadError:
            return "Could not read the CSV file."
        case .timezoneConversionFailed:
            return "Could not convert timezone information."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidFormat:
            return "Please ensure the file is a valid CSV file."
        case .missingColumns:
            return "The CSV must contain 'Start Text' and 'Time Tracked' columns."
        case .invalidDate:
            return "Please check that dates are in the format 'MM/dd/yyyy, h:mm:ss a zzz'."
        case .invalidTime:
            return "Please check that time values are valid numbers."
        case .emptyFile:
            return "Please select a CSV file that contains data."
        case .fileReadError:
            return "Please check that the file is not corrupted and you have permission to read it."
        case .timezoneConversionFailed:
            return "Please check that timezone information is present in the date strings."
        }
    }
}

