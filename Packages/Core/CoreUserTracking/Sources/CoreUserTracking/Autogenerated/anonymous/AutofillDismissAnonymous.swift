import Foundation

extension AnonymousEvent {

public struct `AutofillDismiss`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`dismissType`: Definition.DismissType, `domain`: Definition.Domain, `isNativeApp`: Bool) {
self.dismissType = dismissType
self.domain = domain
self.isNativeApp = isNativeApp
}
public let dismissType: Definition.DismissType
public let domain: Definition.Domain
public let isNativeApp: Bool
public let name = "autofill_dismiss"
}
}
