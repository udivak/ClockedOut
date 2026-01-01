import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weekday
        case weekend
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Weekday Rate")
                            .frame(width: 120, alignment: .leading)
                        TextField("0.00", value: $viewModel.weekdayRate, format: .currency(code: "USD"))
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .weekday)
                            .accessibilityLabel("Weekday hourly rate")
                    }
                    
                    HStack {
                        Text("Weekend Rate")
                            .frame(width: 120, alignment: .leading)
                        TextField("0.00", value: $viewModel.weekendRate, format: .currency(code: "USD"))
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .weekend)
                            .accessibilityLabel("Weekend hourly rate")
                    }
                    
                    if case .invalid(let error) = viewModel.validateRates() {
                        Text(error.userMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Hourly Rates")
            } footer: {
                Text("Set your hourly rates for weekday and weekend work. These rates will be used to calculate your salary.")
            }
            
            Section {
                Button {
                    Task {
                        do {
                            try await viewModel.saveRates()
                        } catch {
                            // Error is handled in viewModel
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(viewModel.isSaving ? "Saving..." : "Save Rates")
                    }
                }
                .disabled(viewModel.isSaving || viewModel.validateRates() != .valid)
                .keyboardShortcut("s", modifiers: .command)
                
                if viewModel.saveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Rates saved successfully")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if let error = viewModel.error {
                Section {
                    Text(error.userMessage)
                        .foregroundColor(.red)
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(
        monthlyRepo: MonthlySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue())
    ))
}

