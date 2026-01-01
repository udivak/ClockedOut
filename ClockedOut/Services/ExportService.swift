import Foundation
import SwiftUI

final class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    @MainActor
    func exportToPDF(report: ReportGenerator.MonthlyReport, to url: URL) throws {
        let pdfView = PDFReportView(report: report)
        let renderer = ImageRenderer(content: pdfView)
        
        var success = false
        
        renderer.render { size, renderContent in
            var box = CGRect(origin: .zero, size: size)
            guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            context.beginPDFPage(nil)
            renderContent(context)
            context.endPDFPage()
            context.closePDF()
            success = true
        }
        
        guard success else {
            throw NSError(domain: "ExportService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate PDF"])
        }
        
        Logger.log("Exported PDF report to: \(url.path)", log: Logger.general)
    }
    
    func exportToCSV(report: ReportGenerator.MonthlyReport, to url: URL) async throws {
        var csvContent = "Week Range,Weekday Hours,Weekend Hours,Total Hours\n"
        
        for weeklyReport in report.weeklyReports {
            let range = weeklyReport.weekRangeString
            let weekday = String(format: "%.2f", weeklyReport.weekdayHours)
            let weekend = String(format: "%.2f", weeklyReport.weekendHours)
            let total = String(format: "%.2f", weeklyReport.totalHours)
            csvContent += "\(range),\(weekday),\(weekend),\(total)\n"
        }
        
        csvContent += "\nTotals,\(report.totals.weekdayHours),\(report.totals.weekendHours),\(report.totals.totalHours)\n"
        csvContent += "Salary,\(report.totals.salary)\n"
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
        Logger.log("Exported CSV report to: \(url.path)", log: Logger.general)
    }
}

// MARK: - PDF View
struct PDFReportView: View {
    let report: ReportGenerator.MonthlyReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Time Tracking Report")
                .font(.largeTitle)
                .bold()
            
            Text(report.summary.formattedMonth)
                .font(.title2)
            
            Divider()
            
            // Totals Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Totals")
                    .font(.headline)
                HStack {
                    Text("Weekday Hours:")
                    Spacer()
                    Text("\(report.totals.weekdayHours)")
                }
                HStack {
                    Text("Weekend Hours:")
                    Spacer()
                    Text("\(report.totals.weekendHours)")
                }
                HStack {
                    Text("Total Hours:")
                    Spacer()
                    Text("\(report.totals.totalHours)")
                        .bold()
                }
                HStack {
                    Text("Salary:")
                    Spacer()
                    Text(CurrencyFormatter.shared.format(report.totals.salary))
                        .bold()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Weekly Breakdown
            Text("Weekly Breakdown")
                .font(.headline)
            
            ForEach(report.weeklyReports) { weeklyReport in
                VStack(alignment: .leading, spacing: 5) {
                    Text(weeklyReport.weekRangeDisplayString)
                        .font(.subheadline)
                        .bold()
                    HStack {
                        Text("Weekday: \(weeklyReport.weekdayHours)h")
                        Spacer()
                        Text("Weekend: \(weeklyReport.weekendHours)h")
                    }
                    .font(.caption)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .frame(width: 600)
    }
}

