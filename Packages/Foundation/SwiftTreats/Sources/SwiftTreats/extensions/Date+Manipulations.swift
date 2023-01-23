import Foundation

public extension Date {
    func substract(days: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -days
        return calendar.date(byAdding: components, to: self)!
    }
}
