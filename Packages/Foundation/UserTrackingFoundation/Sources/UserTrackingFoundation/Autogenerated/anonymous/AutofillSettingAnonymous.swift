import Foundation

extension AnonymousEvent {

  public struct `AutofillSetting`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `disableSetting`: Definition.DisableSetting, `domain`: Definition.Domain? = nil,
      `isNativeApp`: Bool,
      `itemTypeList`: [Definition.ItemType]? = nil
    ) {
      self.disableSetting = disableSetting
      self.domain = domain
      self.isNativeApp = isNativeApp
      self.itemTypeList = itemTypeList
    }
    public let disableSetting: Definition.DisableSetting
    public let domain: Definition.Domain?
    public let isNativeApp: Bool
    public let itemTypeList: [Definition.ItemType]?
    public let name = "autofill_setting"
  }
}
