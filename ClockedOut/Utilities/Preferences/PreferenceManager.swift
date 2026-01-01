import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class PreferenceManager {
    static let shared = PreferenceManager()
    
    private init() {}
    
    @UserDefault(key: "weekdayRate", defaultValue: 90.0)
    var weekdayRate: Double
    
    @UserDefault(key: "weekendRate", defaultValue: 100.0)
    var weekendRate: Double
    
    func saveRates(weekday: Double, weekend: Double) {
        weekdayRate = weekday
        weekendRate = weekend
    }
    
    func loadRates() -> (weekday: Double, weekend: Double) {
        return (weekdayRate, weekendRate)
    }
}

