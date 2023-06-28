import Foundation

public enum AuthenticationGetMethodsAccountType: String, Codable, Equatable, CaseIterable {
    case masterPassword = "masterPassword"
    case invisibleMasterPassword = "invisibleMasterPassword"
}
