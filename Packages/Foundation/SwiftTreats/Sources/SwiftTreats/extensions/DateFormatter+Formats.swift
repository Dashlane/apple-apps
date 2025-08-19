import Foundation

extension DateFormatter {
  public static let birthDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()

  public static let monthAndYear: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/yyyy"
    return formatter
  }()
}
