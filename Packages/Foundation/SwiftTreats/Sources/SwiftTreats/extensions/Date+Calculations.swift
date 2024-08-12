import Foundation

extension Date {
  public func numberOfDays(since startDate: Date) -> Int? {
    let components = Calendar.current.dateComponents([.day], from: startDate, to: self)
    return components.day
  }
}
