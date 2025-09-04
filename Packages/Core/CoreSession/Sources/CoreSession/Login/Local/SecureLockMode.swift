import Foundation
import SwiftTreats

public enum SecureLockMode: Hashable, Sendable {
  public struct PinCodeLock: Hashable, Sendable {
    public let code: String
    public let masterKey: CoreSession.MasterKey

    public init(code: String, masterKey: MasterKey) {
      self.code = code
      self.masterKey = masterKey
    }
  }

  case masterKey
  case biometry(Biometry)
  case pincode(PinCodeLock)
  case biometryAndPincode(biometry: Biometry, pinCodeLock: PinCodeLock)
  case rememberMasterPassword

  public var biometryType: Biometry? {
    switch self {
    case .biometry(let type):
      return type
    case .biometryAndPincode(biometry: let type, _):
      return type
    default:
      return nil
    }
  }
}

extension SecureLockMode {
  public var isBiometric: Bool {
    switch self {
    case .biometry:
      return true
    default:
      return false
    }
  }
}

extension SecureLockMode {
  public var description: String {
    switch self {
    case .biometry(let biometry):
      return biometry.displayableName
    case .biometryAndPincode(let biometry, _):
      return "\(biometry.displayableName) + PIN"
    case .pincode:
      return "PIN"
    case .masterKey:
      return "master key"
    case .rememberMasterPassword:
      return "Remember master password"
    }
  }
}
