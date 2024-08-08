import Foundation

public struct DateDay: Codable, Comparable, Sendable {

  public static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = .current
    return formatter
  }()

  public let date: Date
  public let year: Int
  public let month: Int
  public let day: Int

  public init(date: Date = Date()) {
    self.date = date
    let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
    guard let year = dateComponents.year,
      let month = dateComponents.month,
      let day = dateComponents.day
    else {
      fatalError("Date does not contain correct components")
    }
    self.year = year
    self.month = month
    self.day = day
  }

  public init(year: Int, month: Int, day: Int) {
    let dateComponents = DateComponents(calendar: .current, year: year, month: month, day: day)
    guard let date = dateComponents.date else {
      fatalError("Could not create date in current calendar")
    }
    self.date = date
    self.year = year
    self.month = month
    self.day = day
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let date = DateDay.dateFormatter.date(from: string) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Date not in correct format of \(DateDay.dateFormatter.dateFormat ?? "")")
    }
    self.init(date: date)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let string = DateDay.dateFormatter.string(from: date)
    try container.encode(string)
  }

  public static func == (lhs: DateDay, rhs: DateDay) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
  }

  public static func < (lhs: DateDay, rhs: DateDay) -> Bool {
    return lhs.date < rhs.date
  }
}
