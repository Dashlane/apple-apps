import Foundation

extension AnonymousEvent {

public struct `AutofillSetting`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`disableSetting`: Definition.DisableSetting, `domain`: Definition.Domain, `isNativeApp`: Bool) {
self.disableSetting = disableSetting
self.domain = domain
self.isNativeApp = isNativeApp
}
public let disableSetting: Definition.DisableSetting
public let domain: Definition.Domain
public let isNativeApp: Bool
public let name = "autofill_setting"
}
}
