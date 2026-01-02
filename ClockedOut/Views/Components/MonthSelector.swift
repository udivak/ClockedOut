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
                // Hidden nil tag to prevent SwiftUI warning when selection is temporarily nil
                Text("").tag(nil as String?)
                
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
    struct PreviewWrapper: View {
        @State var selected: String? = "12/2025"
        var body: some View {
            MonthSelector(
                months: [
                    MonthlySummary(month: "12/2025"),
                    MonthlySummary(month: "11/2025")
                ],
                selectedMonth: $selected
            )
        }
    }
    return PreviewWrapper()
}

