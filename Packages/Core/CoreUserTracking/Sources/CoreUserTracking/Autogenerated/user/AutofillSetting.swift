import Foundation

extension UserEvent {

public struct `AutofillSetting`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`disableSetting`: Definition.DisableSetting, `isBulk`: Bool, `itemTypeList`: [Definition.ItemType]? = nil) {
self.disableSetting = disableSetting
self.isBulk = isBulk
self.itemTypeList = itemTypeList
}
public let disableSetting: Definition.DisableSetting
public let isBulk: Bool
public let itemTypeList: [Definition.ItemType]?
public let name = "autofill_setting"
}
}
