import Foundation

public enum ConsentType: String, Codable {
    case emailsOffersAndTips
    case privacyPolicyAndToS
}

public struct Consent: Codable, Equatable {
    public let type: ConsentType
    public let status: Bool

    public init(type: ConsentType, status: Bool) {
        self.type = type
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case type = "consentType"
        case status = "status"
    }
}
