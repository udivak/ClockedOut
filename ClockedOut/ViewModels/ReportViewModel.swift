import Foundation
import SwiftUI
import Combine

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedMonth: String?
    @Published var monthlySummaries: [MonthlySummary] = []
    @Published var weeklyReports: [WeeklyReport] = []
    @Published var totals: ReportGenerator.Totals?
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let monthlyRepo: MonthlySummaryRepository
    private let weeklyRepo: WeeklySummaryRepository
    private let reportGenerator = ReportGenerator.shared
    
    init(monthlyRepo: MonthlySummaryRepository, weeklyRepo: WeeklySummaryRepository) {
        self.monthlyRepo = monthlyRepo
        self.weeklyRepo = weeklyRepo
    }
    
    func loadReports() async {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            monthlySummaries = try await monthlyRepo.fetchAll()
            
            if let selectedMonth = selectedMonth ?? monthlySummaries.first?.month {
                try await selectMonth(selectedMonth)
            }
        } catch let error as AppError {
            self.error = error
        } catch {
            self.error = DatabaseError.queryFailed("fetchAll", error)
        }
    }
    
    func selectMonth(_ month: String) async throws {
        selectedMonth = month
        
        guard let summary = try await monthlyRepo.fetch(month: month) else {
            weeklyReports = []
            totals = nil
            return
        }
        
        // Fetch weekly summaries
        guard let monthId = summary.id else {
            weeklyReports = []
            totals = ReportGenerator.Totals(
                weekdayHours: summary.weekdayHours,
                weekendHours: summary.weekendHours,
                salary: summary.salary
            )
            return
        }
        
        let weeklySummaries = try await weeklyRepo.fetch(for: monthId)
        weeklyReports = weeklySummaries.compactMap { $0.toWeeklyReport() }
        
        totals = ReportGenerator.Totals(
            weekdayHours: summary.weekdayHours,
            weekendHours: summary.weekendHours,
            salary: summary.salary
        )
    }
    
    func refresh() async {
        await loadReports()
    }
    
    func generateReport() -> ReportGenerator.MonthlyReport? {
        guard let selectedMonth = selectedMonth,
              let summary = monthlySummaries.first(where: { $0.month == selectedMonth }),
              totals != nil else {
            return nil
        }
        
        return reportGenerator.generateMonthlyReport(
            summary: summary,
            weeklyReports: weeklyReports
        )
    }
}

