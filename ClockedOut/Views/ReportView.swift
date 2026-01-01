import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ReportView: View {
    @ObservedObject var viewModel: ReportViewModel
    @State private var showExportError = false
    @State private var exportErrorMessage = ""
    @State private var showExportSuccess = false
    
    enum ExportFormat {
        case pdf
        case csv
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                LoadingView(message: "Loading reports...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            } else if viewModel.monthlySummaries.isEmpty {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "No Reports",
                    message: "Import a CSV file to generate your first report",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                contentView
            }
        }
        .task {
            await viewModel.loadReports()
        }
        .alert("Export Successful", isPresented: $showExportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Report has been saved successfully.")
        }
        .alert("Export Failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportErrorMessage)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            // Month selector and export button
            HStack {
                MonthSelector(
                    months: viewModel.monthlySummaries,
                    selectedMonth: Binding(
                        get: { viewModel.selectedMonth },
                        set: { month in
                            if let month = month {
                                Task {
                                    try? await viewModel.selectMonth(month)
                                }
                            }
                        }
                    )
                )
                
                Spacer()
                
                if viewModel.generateReport() != nil {
                    Menu {
                        Button("Export as PDF") {
                            exportReport(format: .pdf)
                        }
                        Button("Export as CSV") {
                            exportReport(format: .csv)
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export report")
                }
            }
            .padding(.horizontal)
            
            if let totals = viewModel.totals {
                // Totals section
                HStack(spacing: 16) {
                    StatCard(
                        title: "Weekday Hours",
                        value: totals.weekdayHours.formatAsDecimalHours(),
                        color: .blue
                    )
                    StatCard(
                        title: "Weekend Hours",
                        value: totals.weekendHours.formatAsDecimalHours(),
                        color: .orange
                    )
                    StatCard(
                        title: "Total Hours",
                        value: totals.totalHours.formatAsDecimalHours(),
                        color: .green
                    )
                    StatCard(
                        title: "Salary",
                        value: CurrencyFormatter.shared.format(totals.salary),
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // Weekly reports
            if viewModel.weeklyReports.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Weekly Data",
                    message: "No weekly breakdown available for this month"
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 300), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.weeklyReports) { report in
                            WeeklyReportCard(report: report)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.weeklyReports.count)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func exportReport(format: ExportFormat) {
        guard let report = viewModel.generateReport() else { return }
        
        let panel = NSSavePanel()
        let sanitizedMonth = (viewModel.selectedMonth ?? "unknown")
            .replacingOccurrences(of: "/", with: "-")
        
        let fileExtension = format == .pdf ? "pdf" : "csv"
        panel.nameFieldStringValue = "report-\(sanitizedMonth).\(fileExtension)"
        panel.allowedContentTypes = format == .pdf ? [.pdf] : [.commaSeparatedText]
        panel.canCreateDirectories = true
        panel.title = "Export Report"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            Task { @MainActor in
                do {
                    switch format {
                    case .pdf:
                        try ExportService.shared.exportToPDF(report: report, to: url)
                    case .csv:
                        try await ExportService.shared.exportToCSV(report: report, to: url)
                    }
                    showExportSuccess = true
                    Logger.log("File saved to: \(url.path)", log: Logger.general)
                } catch {
                    exportErrorMessage = error.localizedDescription
                    showExportError = true
                    Logger.log("Export failed: \(error)", log: Logger.general)
                }
            }
        }
    }
}

#Preview {
    ReportView(viewModel: ReportViewModel(
        monthlyRepo: MonthlySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue()),
        weeklyRepo: WeeklySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue())
    ))
}
