import Foundation

public struct AccountCreateUserConsents: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case consentType = "consentType"
        case status = "status"
    }

    public let consentType: AccountCreateUserConsentType

        public let status: Bool

    public init(consentType: AccountCreateUserConsentType, status: Bool) {
        self.consentType = consentType
        self.status = status
    }
}
