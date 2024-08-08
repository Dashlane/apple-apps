import DashlaneAPI
import Foundation

extension CoreSession.AccountType {
  public init(_ type: DashlaneAPI.AccountType) throws {
    switch type {
    case .invisibleMasterPassword:
      self = .invisibleMasterPassword
    case .masterPassword:
      self = .masterPassword
    case .undecodable:
      throw UndecodableCaseError(DashlaneAPI.AccountType.self)
    }
  }
}
