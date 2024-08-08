import Foundation

extension DateFormatter {
  public static let mediumDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    return dateFormatter
  }()

  public static let birthDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()
}
