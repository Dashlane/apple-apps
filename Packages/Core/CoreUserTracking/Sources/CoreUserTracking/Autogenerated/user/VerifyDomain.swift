import Foundation

extension UserEvent {

public struct `VerifyDomain`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`domainVerificationStep`: Definition.DomainVerificationStep) {
self.domainVerificationStep = domainVerificationStep
}
public let domainVerificationStep: Definition.DomainVerificationStep
public let name = "verify_domain"
}
}
