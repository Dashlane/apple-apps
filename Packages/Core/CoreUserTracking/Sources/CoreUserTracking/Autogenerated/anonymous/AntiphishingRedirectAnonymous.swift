import Foundation

extension AnonymousEvent {

public struct `AntiphishingRedirect`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`phishingDomain`: Definition.Domain, `redirectDomain`: Definition.Domain) {
self.phishingDomain = phishingDomain
self.redirectDomain = redirectDomain
}
public let name = "antiphishing_redirect"
public let phishingDomain: Definition.Domain
public let redirectDomain: Definition.Domain
}
}
