import Foundation
import SwiftUI
import Combine

@MainActor
final class ImportViewModel: ObservableObject {
    @Published var isImporting = false
    @Published var importProgress: Double = 0.0
    @Published var error: AppError?
    @Published var preview: ImportPreview?
    
    // Rate input properties
    @Published var weekdayRate: Double = 90.0
    @Published var weekendRate: Double = 100.0
    @Published var calculatedSalary: Double = 0.0
    @Published var rateValidationError: String?
    @Published var isRatesValid: Bool = false
    
    // Notification properties
    @Published var notificationMessage: String?
    @Published var notificationType: NotificationType = .success
    
    private var cachedEntries: [TimeEntry] = []
    private var cachedMonth: String?
    
    private let csvParser = CSVParser.shared
    private let timeCalculator = TimeCalculator.shared
    private let monthlyRepo: MonthlySummaryRepository
    private let weeklyRepo: WeeklySummaryRepository
    
    init(monthlyRepo: MonthlySummaryRepository, weeklyRepo: WeeklySummaryRepository) {
        self.monthlyRepo = monthlyRepo
        self.weeklyRepo = weeklyRepo
        loadSavedRates()
    }
    
    func loadSavedRates() {
        let rates = PreferenceManager.shared.loadRates()
        weekdayRate = rates.weekday
        weekendRate = rates.weekend
    }
    
    func showNotification(_ message: String, type: NotificationType) {
        notificationMessage = message
        notificationType = type
        
        // Auto-hide after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            notificationMessage = nil
        }
    }
    
    func cancelPreview() {
        preview = nil
        showNotification("Import cancelled", type: .success)
    }
    
    func validateAndCalculateSalary() {
        do {
            try InputValidator.validateRate(weekdayRate, fieldName: "Weekday Rate")
            try InputValidator.validateRate(weekendRate, fieldName: "Weekend Rate")
            
            guard let preview = preview else { return }
            calculatedSalary = (preview.weekdayHours * weekdayRate) + (preview.weekendHours * weekendRate)
            isRatesValid = true
            rateValidationError = nil
        } catch let error as ValidationError {
            isRatesValid = false
            rateValidationError = error.localizedDescription
        } catch {
            isRatesValid = false
            rateValidationError = error.localizedDescription
        }
    }
    
    func importFile(at url: URL) async throws {
        isImporting = true
        importProgress = 0.0
        error = nil
        isRatesValid = false
        rateValidationError = nil
        calculatedSalary = 0.0
        loadSavedRates()
        
        defer {
            isImporting = false
            importProgress = 1.0
        }
        
        do {
            // Parse CSV
            importProgress = 0.2
            let entries = try csvParser.parse(file: url)
            
            guard !entries.isEmpty else {
                throw ParserError.emptyFile
            }
            
            // Calculate totals
            importProgress = 0.4
            let totals = timeCalculator.calculateMonthlyTotals(entries)
            guard let month = timeCalculator.determineMonth(from: entries) else {
                throw ParserError.invalidFormat("Could not determine month from entries")
            }
            
            // Check if month exists
            importProgress = 0.6
            let monthExists = try await monthlyRepo.exists(month: month)
            
            if monthExists {
                // Create preview for user confirmation
                let rates = PreferenceManager.shared.loadRates()
                let salary = (totals.weekdayHours * rates.weekday) + (totals.weekendHours * rates.weekend)
                
                // Cache entries and month for confirmation
                cachedEntries = entries
                cachedMonth = month
                
                preview = ImportPreview(
                    month: month,
                    weekdayHours: totals.weekdayHours,
                    weekendHours: totals.weekendHours,
                    entryCount: entries.count,
                    salary: salary,
                    existingMonth: true
                )
                importProgress = 1.0
                showNotification("File loaded successfully", type: .success)
                return // User needs to confirm
            }
            
            // Cache for direct import
            cachedEntries = entries
            cachedMonth = month
            
            let rates = PreferenceManager.shared.loadRates()
            let salary = (totals.weekdayHours * rates.weekday) + (totals.weekendHours * rates.weekend)
            
            // Show preview for new month
            preview = ImportPreview(
                month: month,
                weekdayHours: totals.weekdayHours,
                weekendHours: totals.weekendHours,
                entryCount: entries.count,
                salary: salary,
                existingMonth: false
            )
            importProgress = 1.0
            showNotification("File loaded successfully", type: .success)
            
        } catch let error as AppError {
            self.error = error
            showNotification("Error: \(error.localizedDescription)", type: .error)
            throw error
        } catch {
            let appError = ParserError.fileReadError(error)
            self.error = appError
            showNotification("Error: \(appError.localizedDescription)", type: .error)
            throw appError
        }
    }
    
    func confirmImport(action: ImportAction) async throws {
        guard let currentPreview = preview else {
            throw NSError(domain: "ImportViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No preview available"])
        }
        
        guard !cachedEntries.isEmpty, let month = cachedMonth else {
            throw NSError(domain: "ImportViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Entries not available"])
        }
        
        let isReplacing = currentPreview.existingMonth
        
        isImporting = true
        importProgress = 0.0
        
        defer {
            isImporting = false
            importProgress = 1.0
        }
        
        let finalEntries = cachedEntries
        let finalMonth = month
        
        let totals = timeCalculator.calculateMonthlyTotals(finalEntries)
        // Use the user-entered rates and calculated salary from the view model
        let salary = calculatedSalary
        
        importProgress = 0.3
        
        // Generate weekly reports
        let weeklyReports = timeCalculator.generateWeeklyReports(from: finalEntries)
        importProgress = 0.5
        
        // Save monthly summary with user-entered rates
        var monthlySummary = MonthlySummary(
            month: finalMonth,
            weekdayHours: totals.weekdayHours,
            weekendHours: totals.weekendHours,
            weekdayRate: weekdayRate,
            weekendRate: weekendRate,
            salary: salary
        )
        
        // Persist rates for future imports
        PreferenceManager.shared.saveRates(weekday: weekdayRate, weekend: weekendRate)
        
        if action == .accumulate {
            if let existing = try await monthlyRepo.fetch(month: finalMonth) {
                monthlySummary.weekdayHours += existing.weekdayHours
                monthlySummary.weekendHours += existing.weekendHours
                monthlySummary.recalculateSalary()
            }
        }
        
        importProgress = 0.7
        try await monthlyRepo.save(monthlySummary)
        
        // Get the saved summary to get the ID
        guard let savedSummary = try await monthlyRepo.fetch(month: finalMonth) else {
            throw DatabaseError.recordNotFound(finalMonth)
        }
        
        // Save weekly summaries
        importProgress = 0.9
        let weeklySummaries = weeklyReports.map { report in
            let formatter = Foundation.DateFormatter.iso8601Formatter
            return WeeklySummary(
                monthId: savedSummary.id!,
                weekStartDate: formatter.string(from: report.weekStartDate),
                weekEndDate: formatter.string(from: report.weekEndDate),
                weekdayHours: report.weekdayHours,
                weekendHours: report.weekendHours
            )
        }
        
        try await weeklyRepo.save(weeklySummaries, for: savedSummary.id!)
        
        importProgress = 1.0
        self.preview = nil
        self.cachedEntries = []
        self.cachedMonth = nil
        showNotification(isReplacing ? "Report replaced successfully" : "Report saved successfully", type: .success)
    }
    
    func previewImport(file url: URL) async throws -> ImportPreview {
        let entries = try csvParser.parse(file: url)
        guard !entries.isEmpty else {
            throw ParserError.emptyFile
        }
        
        let totals = timeCalculator.calculateMonthlyTotals(entries)
        guard let month = timeCalculator.determineMonth(from: entries) else {
            throw ParserError.invalidFormat("Could not determine month")
        }
        
        let rates = PreferenceManager.shared.loadRates()
        let salary = (totals.weekdayHours * rates.weekday) + (totals.weekendHours * rates.weekend)
        let monthExists = try await monthlyRepo.exists(month: month)
        
        return ImportPreview(
            month: month,
            weekdayHours: totals.weekdayHours,
            weekendHours: totals.weekendHours,
            entryCount: entries.count,
            salary: salary,
            existingMonth: monthExists
        )
    }
}

enum ImportAction {
    case replace
    case accumulate
    case cancel
}

enum NotificationType {
    case success
    case error
    
    var color: Color {
        switch self {
        case .success: return Color(red: 0.2, green: 0.8, blue: 0.2)
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

struct ImportPreview {
    let month: String
    let weekdayHours: Double
    let weekendHours: Double
    let entryCount: Int
    let salary: Double
    let existingMonth: Bool
}

