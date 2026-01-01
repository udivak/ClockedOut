import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @ObservedObject var viewModel: ImportViewModel
    @State private var isFilePickerPresented = false
    @State private var draggedOver = false
    @State private var selectedFile: URL?
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                if viewModel.isImporting {
                    LoadingView(
                        message: "Importing CSV file...",
                        progress: viewModel.importProgress
                    )
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.error = nil
                    }
                } else if let preview = viewModel.preview {
                    ImportPreviewView(preview: preview, viewModel: viewModel)
                } else {
                    ImportDropZone(
                        draggedOver: $draggedOver,
                        isFilePickerPresented: $isFilePickerPresented,
                        onDrop: handleDrop
                    )
                }
            }
            
            // Notification overlay
            if let message = viewModel.notificationMessage {
                VStack {
                    NotificationBanner(message: message, type: viewModel.notificationType)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: viewModel.notificationMessage)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.commaSeparatedText, .text],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .onDrop(of: [.fileURL], isTargeted: $draggedOver) { providers in
            handleDrop(providers: providers)
        }
        .onAppear {
            // Set up keyboard shortcut
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
            if let data = item as? Data,
               let url = URL(dataRepresentation: data, relativeTo: nil) {
                Task { @MainActor in
                    await handleFileURL(url)
                }
            }
        }
        
        return true
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                Task { @MainActor in
                    await handleFileURL(url)
                }
            }
        case .failure(let error):
            Task { @MainActor in
                viewModel.error = ParserError.fileReadError(error)
            }
        }
    }
    
    private func handleFileURL(_ url: URL) async {
        do {
            try await viewModel.importFile(at: url)
        } catch {
            // Error is set in viewModel
        }
    }
}

struct ImportDropZone: View {
    @Binding var draggedOver: Bool
    @Binding var isFilePickerPresented: Bool
    let onDrop: ([NSItemProvider]) -> Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(draggedOver ? .blue : .secondary)
                .accessibilityHidden(true)
            
            Text("Import CSV File")
                .font(.title)
                .bold()
            
            Text("Drag and drop a CSV file here, or click to browse")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Browse Files") {
                isFilePickerPresented = true
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Browse for CSV file")
        }
        .frame(maxWidth: 400, maxHeight: 300)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(draggedOver ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            draggedOver ? Color.blue : Color.gray.opacity(0.3),
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: draggedOver ? [10, 5] : []
                            )
                        )
                )
        )
    }
}

struct ImportPreviewView: View {
    let preview: ImportPreview
    @ObservedObject var viewModel: ImportViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Preview")
                .font(.title)
                .bold()
            
            // Hours Summary
            VStack(alignment: .leading, spacing: 12) {
                PreviewRow(label: "Month", value: preview.month)
                PreviewRow(label: "Entries", value: "\(preview.entryCount)")
                PreviewRow(label: "Weekday Hours", value: preview.weekdayHours.formatAsDecimalHours())
                PreviewRow(label: "Weekend Hours", value: preview.weekendHours.formatAsDecimalHours())
                PreviewRow(label: "Total Hours", value: (preview.weekdayHours + preview.weekendHours).formatAsDecimalHours())
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Divider()
            
            // Rate Input Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Hourly Rates")
                    .font(.headline)
                
                HStack {
                    Text("Weekday Rate:")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("90", value: $viewModel.weekdayRate, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .accessibilityLabel("Weekday hourly rate")
                }
                
                HStack {
                    Text("Weekend Rate:")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("100", value: $viewModel.weekendRate, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .accessibilityLabel("Weekend hourly rate")
                }
                
                if let error = viewModel.rateValidationError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button("Calculate Salary") {
                    viewModel.validateAndCalculateSalary()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Calculate salary based on rates")
                
                if viewModel.isRatesValid {
                    PreviewRow(label: "Calculated Salary", value: CurrencyFormatter.shared.format(viewModel.calculatedSalary))
                        .padding(.top, 8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            if preview.existingMonth {
                Text("This month already exists in the database.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 16) {
                Button("Delete") {
                    viewModel.cancelPreview()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityLabel("Cancel and go back")
                
                Button(preview.existingMonth ? "Replace" : "Save") {
                    Task {
                        do {
                            try await viewModel.confirmImport(action: .replace)
                        } catch {
                            // Error handled in viewModel
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.2, green: 0.85, blue: 0.3))
                .disabled(!viewModel.isRatesValid)
                .accessibilityLabel(preview.existingMonth ? "Replace existing report" : "Save report to database")
            }
        }
        .padding(40)
        .frame(maxWidth: 500)
    }
}

struct PreviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct NotificationBanner: View {
    let message: String
    let type: NotificationType
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(type.color)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.top, 20)
    }
}

#Preview {
    ImportView(viewModel: ImportViewModel(
        monthlyRepo: MonthlySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue()),
        weeklyRepo: WeeklySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue())
    ))
}

