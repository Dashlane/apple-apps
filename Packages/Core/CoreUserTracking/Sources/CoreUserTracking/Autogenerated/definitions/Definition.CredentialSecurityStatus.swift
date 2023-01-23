import Foundation

extension Definition {

public struct `CredentialSecurityStatus`: Encodable {
public init(`isCompromised`: Bool? = nil, `isExcluded`: Bool? = nil, `isReused`: Bool? = nil, `isWeak`: Bool? = nil) {
self.isCompromised = isCompromised
self.isExcluded = isExcluded
self.isReused = isReused
self.isWeak = isWeak
}
public let isCompromised: Bool?
public let isExcluded: Bool?
public let isReused: Bool?
public let isWeak: Bool?
}
}