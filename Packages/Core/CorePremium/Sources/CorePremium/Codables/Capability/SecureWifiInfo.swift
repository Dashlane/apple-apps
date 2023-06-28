import Foundation

public enum SecureWifiUnavailableReason: String, Decodable {
    case premium = "not_premium"
    case team = "in_team"
    case payment = "no_payment"
    case unpaidFamilyMember = "is_unpaid_family_member"
    case none = ""
}
