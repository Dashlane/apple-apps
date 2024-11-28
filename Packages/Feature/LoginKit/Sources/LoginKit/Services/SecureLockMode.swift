import CoreKeychain
import DashTypes
import Foundation
import SwiftTreats

public enum SecureLockMode: Equatable {
  public struct PinCodeLock: Equatable {
    public let code: String
    public let attempts: PinCodeAttempts
    public let masterKey: DashTypes.MasterKey

    public init(code: String, attempts: PinCodeAttempts, masterKey: MasterKey) {
      self.code = code
      self.attempts = attempts
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
