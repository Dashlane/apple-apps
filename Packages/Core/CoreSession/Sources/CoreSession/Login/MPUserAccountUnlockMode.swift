import CoreNetworking
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine

public enum MPUserAccountUnlockMode: Hashable, Sendable {
  case twoFactor(serverKey: ServerKey, accountRecoveryAuthTicket: AuthTicket? = nil)
  case masterPasswordOnly

  var accountRecoveryAuthTicket: AuthTicket? {
    switch self {
    case let .twoFactor(_, authTicket):
      return authTicket
    case .masterPasswordOnly:
      return nil
    }
  }

  var serverKey: ServerKey? {
    switch self {
    case let .twoFactor(serverKey, _):
      return serverKey
    case .masterPasswordOnly:
      return nil
    }
  }

}
