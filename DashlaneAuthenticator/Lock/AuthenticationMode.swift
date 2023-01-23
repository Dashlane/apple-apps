import Foundation
import CoreKeychain
import SwiftTreats
import DashlaneAppKit
import LoginKit

enum AuthenticationMode: Identifiable {
    case biometry(Biometry)
    case pincode(code: String, attempts: PinCodeAttempts, masterKey: CoreKeychain.MasterKey)
    case biometryAndPincode(code: String, attempts: PinCodeAttempts, _ masterKey: CoreKeychain.MasterKey, _ biometry: Biometry)
    var id: String {
        switch self {
        case .biometry:
            return "biometry"
        case .pincode:
            return "pincode"
        case .biometryAndPincode:
            return "pincodeAndBiometry"
        }
    }
}

extension AuthenticationMode {
    var lockLabel: String {
        switch self {
        case .biometry(let type):
            return L10n.Localizable.passwordappOnboardingSubtitle(type.displayableName)
        case .pincode:
            return L10n.Localizable.passwordappOnboardingSubtitlePin
        case let .biometryAndPincode(_, _, _, type):
            return L10n.Localizable.passwordappOnboardingFallbackPinSubtitle(type.displayableName)
        }
    }
    
    var displayName: String {
        switch self {
        case .biometry(let type):
            return type.displayableName
        case .pincode:
            return "PIN"
        case let .biometryAndPincode(_, _, _, type):
            return type.displayableName
        }
    }
}

extension SecureLockMode {
    var authenticationMode: AuthenticationMode? {
        switch self {
        case .biometry(let value):
            return .biometry(value)
        case let .pincode(code, attempts, masterKey):
            return .pincode(code: code, attempts: attempts, masterKey: masterKey)
        case let .biometryAndPincode(biometry, code, attempts, masterKey):
            return .biometryAndPincode(code: code, attempts: attempts, masterKey, biometry)
        default:
            return nil
        }
    }
}

