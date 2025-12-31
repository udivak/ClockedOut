import SwiftUI

struct MonthSelector: View {
    let months: [MonthlySummary]
    @Binding var selectedMonth: String?
    
    var body: some View {
        if months.isEmpty {
            Text("No months available")
                .foregroundColor(.secondary)
        } else {
            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.month) { summary in
                    Text(summary.formattedMonth)
                        .tag(summary.month as String?)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Select month")
        }
    }
}

#Preview {
    @Previewable @State var selected: String? = "12/2025"
    return MonthSelector(
        months: [
            MonthlySummary(month: "12/2025"),
            MonthlySummary(month: "11/2025")
        ],
        selectedMonth: $selected
    )
}

