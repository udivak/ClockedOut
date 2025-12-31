import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    init(title: String, value: String, color: Color = .blue) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HStack {
        StatCard(title: "Weekday Hours", value: "27.5", color: .blue)
        StatCard(title: "Weekend Hours", value: "10", color: .orange)
    }
    .padding()
}

