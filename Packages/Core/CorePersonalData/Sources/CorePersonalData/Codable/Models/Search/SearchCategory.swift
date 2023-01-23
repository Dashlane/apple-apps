import Foundation

public enum SearchCategory: Int {
    case personalInfo
    case id
    case secureNote
    case payment
    case credential
    
            var priority: Int {
        return rawValue
    }
}
