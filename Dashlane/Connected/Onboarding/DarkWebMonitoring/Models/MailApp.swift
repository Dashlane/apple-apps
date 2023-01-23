import Foundation

enum MailApp: String, CaseIterable {
    case appleMail
    case gmail
    case outlook
    case spark
    case yahooMail

    var urlScheme: String {
        switch self {
        case .appleMail:
            return "message://"
        case .gmail:
            return "googlegmail://"
        case .outlook:
            return "ms-outlook://"
        case .spark:
            return "readdle-spark://"
        case .yahooMail:
            return "ymail://"
        }
    }
}
