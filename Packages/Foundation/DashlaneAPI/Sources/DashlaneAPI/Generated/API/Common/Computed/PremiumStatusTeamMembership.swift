import Foundation

public struct PremiumStatusTeamMembership: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case teamAdmins = "teamAdmins"
    case billingAdmins = "billingAdmins"
    case isTeamAdmin = "isTeamAdmin"
    case isBillingAdmin = "isBillingAdmin"
    case isSSOUser = "isSSOUser"
    case isGroupManager = "isGroupManager"
  }

  public let teamAdmins: [String]
  public let billingAdmins: [String]
  public let isTeamAdmin: Bool
  public let isBillingAdmin: Bool
  public let isSSOUser: Bool
  public let isGroupManager: Bool

  public init(
    teamAdmins: [String], billingAdmins: [String], isTeamAdmin: Bool, isBillingAdmin: Bool,
    isSSOUser: Bool, isGroupManager: Bool
  ) {
    self.teamAdmins = teamAdmins
    self.billingAdmins = billingAdmins
    self.isTeamAdmin = isTeamAdmin
    self.isBillingAdmin = isBillingAdmin
    self.isSSOUser = isSSOUser
    self.isGroupManager = isGroupManager
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(teamAdmins, forKey: .teamAdmins)
    try container.encode(billingAdmins, forKey: .billingAdmins)
    try container.encode(isTeamAdmin, forKey: .isTeamAdmin)
    try container.encode(isBillingAdmin, forKey: .isBillingAdmin)
    try container.encode(isSSOUser, forKey: .isSSOUser)
    try container.encode(isGroupManager, forKey: .isGroupManager)
  }
}
