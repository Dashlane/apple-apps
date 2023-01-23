import Foundation

public struct TeamMembership: Decodable {
    public let teamId: Int
    public let billingAdmins: [String]
    public let isBillingAdmin: Bool
}
