import Foundation
import CoreKeychain
import SwiftTreats

public enum SecureLockMode: Equatable {
    public struct PinCodeLock: Equatable {
        public let code: String
        public let attempts: PinCodeAttempts 
        public let masterKey: CoreKeychain.MasterKey

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
        case .biometryAndPincode(biometry: let biometry, _):
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
