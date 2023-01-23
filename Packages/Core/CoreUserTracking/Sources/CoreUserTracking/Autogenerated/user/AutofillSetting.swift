import Foundation

extension UserEvent {

public struct `AutofillSetting`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`disableSetting`: Definition.DisableSetting) {
self.disableSetting = disableSetting
}
public let disableSetting: Definition.DisableSetting
public let name = "autofill_setting"
}
}
