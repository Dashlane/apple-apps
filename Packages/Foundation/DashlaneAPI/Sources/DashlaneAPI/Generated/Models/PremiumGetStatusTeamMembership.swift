import Foundation

public struct PremiumGetStatusTeamMembership: Codable, Equatable {

    public let teamAdmins: [String]

    public let billingAdmins: [String]

    public let isTeamAdmin: Bool

    public let isBillingAdmin: Bool

    public let isSSOUser: Bool

    public let isGroupManager: Bool

    public init(teamAdmins: [String], billingAdmins: [String], isTeamAdmin: Bool, isBillingAdmin: Bool, isSSOUser: Bool, isGroupManager: Bool) {
        self.teamAdmins = teamAdmins
        self.billingAdmins = billingAdmins
        self.isTeamAdmin = isTeamAdmin
        self.isBillingAdmin = isBillingAdmin
        self.isSSOUser = isSSOUser
        self.isGroupManager = isGroupManager
    }
}
