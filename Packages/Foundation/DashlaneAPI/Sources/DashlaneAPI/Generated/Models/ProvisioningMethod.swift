import Foundation

public enum ProvisioningMethod: String, Codable, Equatable, CaseIterable {
    case user = "USER"
    case tac = "TAC"
    case ad = "AD"
    case scim = "SCIM"
}
