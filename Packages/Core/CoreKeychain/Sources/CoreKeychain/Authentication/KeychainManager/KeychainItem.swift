import Foundation

enum KeychainItem {
  case masterKey
  case resetContainer

  case serverKey

  var keychainItemClass: CFString {
    switch self {
    case .masterKey:
      return kSecClassGenericPassword
    case .resetContainer:
      return kSecClassGenericPassword
    case .serverKey:
      return kSecClassGenericPassword
    }
  }

  var keychainItemService: CFString {
    switch self {
    case .serverKey:
      return "otp2ServerKey" as CFString
    case .masterKey:
      return kSecClassGenericPassword
    case .resetContainer:
      return "ResetMasterPasswordWithBiometrics" as CFString
    }
  }
}
