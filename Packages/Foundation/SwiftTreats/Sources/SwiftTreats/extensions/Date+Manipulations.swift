import Foundation

extension Date {
  public func substract(days: Int) -> Date {
    let calendar = Calendar.current
    var components = DateComponents()
    components.day = -days
    return calendar.date(byAdding: components, to: self)!
  }
}
