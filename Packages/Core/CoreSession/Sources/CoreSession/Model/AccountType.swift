import DashlaneAPI
import Foundation

extension AuthenticationMethodsAccountType {
  public var userAccountType: AccountType {
    get throws {
      switch self {
      case .masterPassword:
        return .masterPassword
      case .invisibleMasterPassword:
        return .invisibleMasterPassword
      case .undecodable:
        throw UndecodableCaseError(AuthenticationMethodsAccountType.self)
      }
    }
  }
}
