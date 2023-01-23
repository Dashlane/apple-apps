import Foundation

enum ConfigurationScreenLogEvent: String, TachyonLoggable {
    case displayed = "show"

    var logData: TachyonLogData {
        return TachyonLogData(type: "TachyonActivated", subType: nil, action: self.rawValue, subAction: nil)
    }
}
