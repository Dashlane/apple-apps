import Foundation

extension AnonymousEvent {

public struct `RemoveTwoFactorAuthenticationFromCredential`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`authenticatorIssuerId`: String? = nil, `domain`: Definition.Domain, `space`: Definition.Space) {
self.authenticatorIssuerId = authenticatorIssuerId
self.domain = domain
self.space = space
}
public let authenticatorIssuerId: String?
public let domain: Definition.Domain
public let name = "remove_two_factor_authentication_from_credential"
public let space: Definition.Space
}
}
