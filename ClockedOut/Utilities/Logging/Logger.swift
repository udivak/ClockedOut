import Foundation
import OSLog

struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.clockedout"
    
    static let general = OSLog(subsystem: subsystem, category: "general")
    static let database = OSLog(subsystem: subsystem, category: "database")
    static let parser = OSLog(subsystem: subsystem, category: "parser")
    static let calculator = OSLog(subsystem: subsystem, category: "calculator")
    
    static func log(_ message: String, level: OSLogType = .default, log: OSLog = general) {
        os_log("%{public}@", log: log, type: level, message)
    }
    
    static func error(_ message: String, error: Error? = nil, log: OSLog = general) {
        if let error = error {
            os_log("%{public}@: %{public}@", log: log, type: .error, message, error.localizedDescription)
        } else {
            os_log("%{public}@", log: log, type: .error, message)
        }
    }
    
    static func debug(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .debug, message)
    }
}

