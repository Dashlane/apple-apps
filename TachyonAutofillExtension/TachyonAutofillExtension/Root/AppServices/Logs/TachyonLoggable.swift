import Foundation

struct TachyonLogData {
    let type: String
    let subType: String?
    let action: String?
    let subAction: String?
    let domain: String?

    init(type: String,
         subType: String? = nil,
         action: String? = nil,
         subAction: String? = nil,
         domain: String? = nil) {
        self.type = type
        self.subType = subType
        self.action = action
        self.subAction = subAction
        self.domain = domain
    }
}

protocol TachyonLoggable {
    var logData: TachyonLogData { get }
}
