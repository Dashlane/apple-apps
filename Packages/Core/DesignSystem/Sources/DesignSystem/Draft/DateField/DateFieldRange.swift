import Foundation

public enum DateFieldRange {
  case closed(ClosedRange<Date>)
  case from(PartialRangeFrom<Date>)
  case through(PartialRangeThrough<Date>)
}

extension Date {
  static func `default`(for range: DateFieldRange?) -> Date {
    switch range {
    case .closed(let range):
      return range.lowerBound
    case .from(let range):
      return range.lowerBound
    case .through(let range):
      return range.upperBound
    case .none:
      return Date()
    }
  }
}

extension DateFieldRange {
  public static var past: DateFieldRange {
    return .through(PartialRangeThrough(Date()))
  }
}

extension DateFieldRange {
  public static var future: DateFieldRange {
    return .from(PartialRangeFrom(Date()))
  }
}
