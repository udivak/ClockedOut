import SwiftUI

struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("Error")
                    .font(.title2)
                    .bold()
                
                Text(error.userMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Error: \(error.userMessage). \(error.recoverySuggestion ?? "")")
            
            if let retryAction = retryAction {
                Button("Retry", action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Retry operation")
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        error: ParserError.invalidFormat("Test error"),
        retryAction: {}
    )
}

