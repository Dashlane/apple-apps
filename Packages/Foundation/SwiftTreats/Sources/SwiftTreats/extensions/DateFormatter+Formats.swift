import Foundation

extension DateFormatter {
    public static let mediumDateFormatter: DateFormatter = {
        let dateFormatter  = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}
