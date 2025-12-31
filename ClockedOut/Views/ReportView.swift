import SwiftUI
import UniformTypeIdentifiers

struct ReportView: View {
    @Bindable var viewModel: ReportViewModel
    @State private var isExportSheetPresented = false
    @State private var exportFormat: ExportFormat = .pdf
    @State private var exportURL: URL?
    
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
        .fileExporter(
            isPresented: $isExportSheetPresented,
            document: nil,
            contentType: exportFormat == .pdf ? .pdf : .commaSeparatedText,
            defaultFilename: "report-\(viewModel.selectedMonth ?? "unknown")"
        ) { result in
            handleExportDialog(result)
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
                            exportFormat = .pdf
                            isExportSheetPresented = true
                        }
                        Button("Export as CSV") {
                            exportFormat = .csv
                            isExportSheetPresented = true
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
    
    private func handleExportDialog(_ result: Result<URL, Error>) {
        guard let report = viewModel.generateReport() else { return }
        
        switch result {
        case .success(let url):
            Task {
                do {
                    switch exportFormat {
                    case .pdf:
                        try await ExportService.shared.exportToPDF(report: report, to: url)
                    case .csv:
                        try await ExportService.shared.exportToCSV(report: report, to: url)
                    }
                } catch {
                    // Handle error
                }
            }
        case .failure:
            break
        }
    }
}

#Preview {
    ReportView(viewModel: ReportViewModel(
        monthlyRepo: MonthlySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue()),
        weeklyRepo: WeeklySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue())
    ))
}
