import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var weekdayRate: Double = 0.0
    @Published var weekendRate: Double = 0.0
    @Published var isSaving = false
    @Published var error: AppError?
    @Published var saveSuccess = false
    
    private let monthlyRepo: MonthlySummaryRepository
    private let preferenceManager = PreferenceManager.shared
    
    init(monthlyRepo: MonthlySummaryRepository) {
        self.monthlyRepo = monthlyRepo
        loadRates()
    }
    
    func loadRates() {
        let rates = preferenceManager.loadRates()
        weekdayRate = rates.weekday
        weekendRate = rates.weekend
    }
    
    func saveRates() async throws {
        // Validate rates
        try InputValidator.validateRate(weekdayRate, fieldName: "Weekday Rate")
        try InputValidator.validateRate(weekendRate, fieldName: "Weekend Rate")
        
        isSaving = true
        error = nil
        saveSuccess = false
        
        defer {
            isSaving = false
        }
        
        do {
            // Save to preferences
            preferenceManager.saveRates(weekday: weekdayRate, weekend: weekendRate)
            
            // Recalculate salaries for all months
            try await monthlyRepo.recalculateAllSalaries()
            
            saveSuccess = true
            
            // Reset success flag after a delay
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                await MainActor.run {
                    saveSuccess = false
                }
            }
        } catch let error as AppError {
            self.error = error
            throw error
        } catch {
            let validationError = ValidationError.invalidRate("\(error.localizedDescription)")
            self.error = validationError
            throw validationError
        }
    }
    
    func validateRates() -> ValidationResult {
        do {
            try InputValidator.validateRate(weekdayRate, fieldName: "Weekday Rate")
            try InputValidator.validateRate(weekendRate, fieldName: "Weekend Rate")
            return .valid
        } catch let error as ValidationError {
            return .invalid(error)
        } catch {
            return .invalid(ValidationError.invalidRate("Unknown error"))
        }
    }
}

enum ValidationResult: Equatable {
    case valid
    case invalid(ValidationError)
    
    static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid):
            return true
        case (.invalid(let lhsError), .invalid(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

