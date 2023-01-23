import Foundation

public struct AccountCreateUserConsents: Codable, Equatable {

    public let consentType: AccountCreateUserConsentType

        public let status: Bool

    public init(consentType: AccountCreateUserConsentType, status: Bool) {
        self.consentType = consentType
        self.status = status
    }
}
