import Foundation

public enum SearchCategory: Int {
    case personalInfo
    case id
    case secureNote
    case payment
    case credential
    case collection

            var priority: Int {
        return rawValue
    }
}
