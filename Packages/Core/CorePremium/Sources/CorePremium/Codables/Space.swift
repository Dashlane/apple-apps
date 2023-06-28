import Foundation

public struct SpaceLogin: Codable, Hashable {
    public init(login: String) {
        self.login = login
    }

    public let login: String
}

public struct SpaceInfo: Codable, Hashable {

    public enum TwoFAEnforcement: String, Codable {
                case login
                case newDevice
                case disabled
    }

    public init(forcedDomainsEnabled: Bool? = nil,
                removeForcedContentEnabled: Bool? = nil,
                teamDomains: [String]? = nil,
                removalGracePeriodPlan: String? = nil,
                fullSeatCountRenewal: Bool? = nil,
                mailVersion: String? = nil,
                teamCaptains: [String: Bool]? = nil,
                name: String? = nil,
                features: [String: Bool]? = nil,
                activeDirectoryToken: String? = nil,
                activeDirectorySyncType: String? = nil,
                idpCertificate: String? = nil,
                mpPersistenceDisabled: Bool? = nil,
                autologinDomainDisabledArray: [String]? = nil,
                sharingDisabled: Bool? = nil,
                emergencyDisabled: Bool? = nil,
                lockOnExit: Bool? = nil,
                recoveryEnabled: Bool? = nil,
                cryptoForcedPayload: String? = nil,
                forceAutomaticLogout: Int? = nil,
                twoFaEnforcement: TwoFAEnforcement? = nil,
                collectSensitiveDataAuditLogsEnabled: Bool? = nil) {
        self.forcedDomainsEnabled = forcedDomainsEnabled
        self.removeForcedContentEnabled = removeForcedContentEnabled
        self.teamDomains = teamDomains
        self.removalGracePeriodPlan = removalGracePeriodPlan
        self.fullSeatCountRenewal = fullSeatCountRenewal
        self.mailVersion = mailVersion
        self.teamCaptains = teamCaptains
        self.name = name
        self.features = features
        self.activeDirectoryToken = activeDirectoryToken
        self.activeDirectorySyncType = activeDirectorySyncType
        self.idpCertificate = idpCertificate
        self.mpPersistenceDisabled = mpPersistenceDisabled
        self.autologinDomainDisabledArray = autologinDomainDisabledArray
        self.sharingDisabled = sharingDisabled
        self.emergencyDisabled = emergencyDisabled
        self.lockOnExit = lockOnExit
        self.recoveryEnabled = recoveryEnabled
        self.cryptoForcedPayload = cryptoForcedPayload
        self.forceAutomaticLogout = forceAutomaticLogout
        self.twoFAEnforced = twoFaEnforcement
        self.collectSensitiveDataAuditLogsEnabled = collectSensitiveDataAuditLogsEnabled
    }

    public let forcedDomainsEnabled: Bool?
    public let removeForcedContentEnabled: Bool?
    public let teamDomains: [String]?
    public let removalGracePeriodPlan: String?
    public let fullSeatCountRenewal: Bool?
    public let mailVersion: String?
    public let teamCaptains: [String: Bool]?
    public let name: String?
    public let features: [String: Bool]?
    public let activeDirectoryToken: String?
    public let activeDirectorySyncType: String?
    public let idpCertificate: String?
    public let mpPersistenceDisabled: Bool?
    public let autologinDomainDisabledArray: [String]?
    public let sharingDisabled: Bool?
    public let emergencyDisabled: Bool?
    public let lockOnExit: Bool?
    public let recoveryEnabled: Bool?
    public let cryptoForcedPayload: String?
    public let forceAutomaticLogout: Int?
    public let twoFAEnforced: TwoFAEnforcement?
    public let collectSensitiveDataAuditLogsEnabled: Bool?
}

public struct Space: Codable, Hashable {
    public init(teamId: String,
                teamName: String? = nil,
                companyName: String? = nil,
                letter: String,
                color: String,
                associatedEmail: String,
                membersNumber: Int,
                teamAdmins: [SpaceLogin],
                billingAdmins: [SpaceLogin],
                isTeamAdmin: Bool,
                isBillingAdmin: Bool,
                isSSOUser: Bool = false,
                joinDate: Date? = nil,
                invitationDate: Date? = nil,
                revokeDate: Date? = nil,
                planType: String,
                status: Space.MembershipStatus,
                info: SpaceInfo,
                shouldDelete: Bool? = false) {
        self.teamId = teamId
        self.teamName = teamName
        self.companyName = companyName
        self.letter = letter
        self.color = color
        self.associatedEmail = associatedEmail
        self.membersNumber = membersNumber
        self.teamAdmins = teamAdmins
        self.billingAdmins = billingAdmins
        self.isTeamAdmin = isTeamAdmin
        self.isBillingAdmin = isBillingAdmin
        self.isSSOUser = isSSOUser
        self.joinDate = joinDate
        self.invitationDate = invitationDate
        self.revokeDate = revokeDate
        self.planType = planType
        self.status = status
        self.info = info
        self.shouldDelete = shouldDelete
    }

    public enum MembershipStatus: String, Codable, Hashable {
        case accepted
        case proposed
        case revoked
        case unknown
    }
    public let teamId: String
    public let teamName: String?
    public let companyName: String?
    public let letter: String
    public let color: String
    public let associatedEmail: String
    public let membersNumber: Int
    public let teamAdmins: [SpaceLogin]
    public let billingAdmins: [SpaceLogin]
    public let isTeamAdmin: Bool
    public let isBillingAdmin: Bool
    public let isSSOUser: Bool?
    public let joinDate: Date?
    public let invitationDate: Date?
    public let revokeDate: Date?
        public let planType: String
    public let status: MembershipStatus
    public let info: SpaceInfo
        public let shouldDelete: Bool?
}
