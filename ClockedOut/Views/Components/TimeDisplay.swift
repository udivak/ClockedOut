import SwiftUI

struct TimeDisplay: View {
    let hours: Double
    let style: DisplayStyle
    
    enum DisplayStyle {
        case decimal
        case hoursMinutes
        case compact
    }
    
    var body: some View {
        Text(formattedValue)
            .font(style == .compact ? .caption : .body)
            .accessibilityLabel("\(formattedValue) hours")
    }
    
    private var formattedValue: String {
        switch style {
        case .decimal:
            return hours.formatAsDecimalHours()
        case .hoursMinutes:
            return hours.formatAsHours()
        case .compact:
            return String(format: "%.1fh", hours)
        }
    }
}

#Preview {
    VStack {
        TimeDisplay(hours: 27.5, style: .decimal)
        TimeDisplay(hours: 27.5, style: .hoursMinutes)
        TimeDisplay(hours: 27.5, style: .compact)
    }
}

