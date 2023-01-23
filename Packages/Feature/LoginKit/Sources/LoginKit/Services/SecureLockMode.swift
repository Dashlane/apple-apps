import Foundation
import CoreKeychain
import SwiftTreats

public enum SecureLockMode: Equatable {
    case masterKey
    case biometry(Biometry)
    case pincode(code: String, attempts: PinCodeAttempts, masterKey: CoreKeychain.MasterKey)
    case biometryAndPincode(biometry: Biometry, code: String, attempts: PinCodeAttempts, masterKey: CoreKeychain.MasterKey)
    case rememberMasterPassword

    public var biometryType: Biometry? {
        switch self {
        case .biometry(let type):
            return type
        case .biometryAndPincode(biometry: let type, _, _, _):
            return type
        default:
            return nil
        }
    }
}

public extension SecureLockMode {
    var isBiometric: Bool {
        switch self {
        case .biometry:
            return true
        default:
            return false
        }
    }
}

public extension SecureLockMode {
    var description: String {
        switch self {
        case .biometry(let biometry):
            return biometry.displayableName
        case .biometryAndPincode(biometry: let biometry, _, _, _):
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

