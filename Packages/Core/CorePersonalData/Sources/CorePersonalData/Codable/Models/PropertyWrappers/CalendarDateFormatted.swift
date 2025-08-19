import Foundation

@propertyWrapper
public struct CalendarDateFormatted: Codable, Equatable {
  static var regularDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  static var twoDigitsYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy-MM-dd"
    return formatter
  }()

  static func date(from string: String) -> Date? {
    let isYearCorrectlyFormatted =
      string.count > 4
      && string.prefix(4).allSatisfy {
        $0.isNumber
      }

    if !isYearCorrectlyFormatted {
      return twoDigitsYearFormatter.date(from: string)
    } else {
      return regularDateFormatter.date(from: string)
    }
  }

  public var wrappedValue: Date?

  public var projectedValue: DateComponents? {
    guard let date = wrappedValue else {
      return nil
    }

    let allComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date)
    return DateComponents(
      year: allComponents.year,
      month: allComponents.month,
      day: allComponents.day)
  }

  public init() {

  }

  public init(rawValue: String?) {
    guard let rawValue = rawValue,
      !rawValue.isEmpty,
      let date = Self.date(from: rawValue)
    else {
      self.wrappedValue = nil
      return
    }

    self.wrappedValue = date
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawDate = try container.decode(String.self)
    guard !rawDate.isEmpty,
      let date = Self.date(from: rawDate)
    else {
      self.wrappedValue = nil
      return
    }

    self.wrappedValue = date
  }

  public init(_ date: Date?) {
    self.wrappedValue = date
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    guard let date = wrappedValue else {
      try container.encodeNil()
      return
    }
    try container.encode(Self.string(from: date))
  }

  public static func string(from date: Date?) -> String? {
    guard let date else {
      return nil
    }
    return Self.regularDateFormatter.string(from: date)
  }
}
