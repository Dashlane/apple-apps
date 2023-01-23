import Foundation

public struct PremiumGetStatusTeamInfo: Codable, Equatable {

    public let membersNumber: Int

    public let planType: String

    public let color: String?

    public let forcedDomainsEnabled: Bool?

    public let letter: String?

    public let recoveryEnabled: Bool?

    public let removeForcedContentEnabled: Bool?

    public let ssoActivationType: String?

    public let ssoEnabled: Bool?

    public let ssoProvisioning: String?

    public let teamDomains: [String]?

    public init(membersNumber: Int, planType: String, color: String? = nil, forcedDomainsEnabled: Bool? = nil, letter: String? = nil, recoveryEnabled: Bool? = nil, removeForcedContentEnabled: Bool? = nil, ssoActivationType: String? = nil, ssoEnabled: Bool? = nil, ssoProvisioning: String? = nil, teamDomains: [String]? = nil) {
        self.membersNumber = membersNumber
        self.planType = planType
        self.color = color
        self.forcedDomainsEnabled = forcedDomainsEnabled
        self.letter = letter
        self.recoveryEnabled = recoveryEnabled
        self.removeForcedContentEnabled = removeForcedContentEnabled
        self.ssoActivationType = ssoActivationType
        self.ssoEnabled = ssoEnabled
        self.ssoProvisioning = ssoProvisioning
        self.teamDomains = teamDomains
    }
}
