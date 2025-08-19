import CoreTypes
import Foundation

public enum MasterKey: Equatable, Codable, Sendable, Hashable {
  case masterPassword(String, serverKey: String? = nil)
  case ssoKey(Data)

  public var serverKey: String? {
    guard case let .masterPassword(_, serverKey) = self else {
      return nil
    }
    return serverKey
  }

  public var secret: EncryptionSecret {
    switch self {
    case let .masterPassword(masterPassword, serverKey):
      if let serverKey = serverKey {
        return .password(serverKey + masterPassword)
      } else {
        return .password(masterPassword)
      }
    case .ssoKey(let key):
      return .key(key)
    }
  }

  public func masterKey(withServerKey serverKey: String?) -> MasterKey {
    switch self {
    case let .masterPassword(masterPassword, _):
      return .masterPassword(masterPassword, serverKey: serverKey)
    default:
      return self
    }
  }

  public static func == (lhs: MasterKey, rhs: MasterKey) -> Bool {
    switch (lhs, rhs) {
    case (let .masterPassword(lhsPassword, _), let .masterPassword(rhsPassword, _)):
      return lhsPassword == rhsPassword
    case (let .ssoKey(lhsData), let .ssoKey(rhsData)):
      return lhsData == rhsData
    default:
      return false
    }
  }
}

extension CoreSession.MasterKey {
  public var keyChainMasterKey: CoreTypes.MasterKey {
    switch self {
    case .masterPassword(let password, _):
      return .masterPassword(password)
    case .ssoKey(let data):
      return .key(data)
    }
  }
}
