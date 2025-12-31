import SwiftUI

struct WeeklyReportCard: View {
    let report: WeeklyReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(report.weekRangeDisplayString)
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(report.weekdayHours.formatAsDecimalHours())
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Weekday hours: \(report.weekdayHours.formatAsDecimalHours())")
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Weekend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(report.weekendHours.formatAsDecimalHours())
                        .font(.title2)
                        .bold()
                        .foregroundColor(.orange)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Weekend hours: \(report.weekendHours.formatAsDecimalHours())")
            }
            
            HStack {
                Text("Total:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(report.totalHours.formatAsDecimalHours())
                    .font(.subheadline)
                    .bold()
            }
            .padding(.top, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total hours: \(report.totalHours.formatAsDecimalHours())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WeeklyReportCard(
        report: WeeklyReport(
            weekStartDate: Date(),
            weekEndDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
            weekdayHours: 27.5,
            weekendHours: 10
        )
    )
    .padding()
}

