import Foundation

extension AnonymousEvent {

public struct `AutofillDisplayIcons`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`domain`: Definition.Domain, `msToIcon`: Int) {
self.domain = domain
self.msToIcon = msToIcon
}
public let domain: Definition.Domain
public let msToIcon: Int
public let name = "autofill_display_icons"
}
}
