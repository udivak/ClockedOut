import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Bindable var viewModel: ImportViewModel
    @State private var isFilePickerPresented = false
    @State private var draggedOver = false
    @State private var selectedFile: URL?
    
    var body: some View {
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
                    onDrop: handleDrop
                )
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
                Task {
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
                Task {
                    await handleFileURL(url)
                }
            }
        case .failure(let error):
            viewModel.error = ParserError.fileReadError(error)
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
                        .stroke(draggedOver ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .strokeStyle(style: draggedOver ? .dashed : .solid)
                )
        )
    }
}

struct ImportPreviewView: View {
    let preview: ImportPreview
    @Bindable var viewModel: ImportViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Preview")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                PreviewRow(label: "Month", value: preview.month)
                PreviewRow(label: "Entries", value: "\(preview.entryCount)")
                PreviewRow(label: "Weekday Hours", value: preview.weekdayHours.formatAsDecimalHours())
                PreviewRow(label: "Weekend Hours", value: preview.weekendHours.formatAsDecimalHours())
                PreviewRow(label: "Total Hours", value: (preview.weekdayHours + preview.weekendHours).formatAsDecimalHours())
                PreviewRow(label: "Salary", value: CurrencyFormatter.shared.format(preview.salary))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            if preview.existingMonth {
                Text("This month already exists in the database.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                HStack {
                    Button("Replace") {
                        Task {
                            do {
                                try await viewModel.confirmImport(action: .replace)
                            } catch {
                                // Error handled in viewModel
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Replace existing month data")
                    
                    Button("Accumulate") {
                        Task {
                            do {
                                try await viewModel.confirmImport(action: .accumulate)
                            } catch {
                                // Error handled in viewModel
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Add to existing month data")
                    
                    Button("Cancel") {
                        viewModel.preview = nil
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Cancel import")
                }
            } else {
                Button("Import") {
                    Task {
                        do {
                            try await viewModel.confirmImport(action: .replace)
                        } catch {
                            // Error handled in viewModel
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Import CSV data")
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

#Preview {
    ImportView(viewModel: ImportViewModel(
        monthlyRepo: MonthlySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue()),
        weeklyRepo: WeeklySummaryRepository(dbQueue: try! DatabaseManager.shared.getDatabaseQueue())
    ))
}

