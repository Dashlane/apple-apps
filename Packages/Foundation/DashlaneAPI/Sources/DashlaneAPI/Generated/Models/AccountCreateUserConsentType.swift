import Foundation

public enum AccountCreateUserConsentType: String, Codable, Equatable, CaseIterable {
    case privacyPolicyAndToS = "privacyPolicyAndToS"
    case emailsOffersAndTips = "emailsOffersAndTips"
}
