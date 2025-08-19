import Foundation

public enum MasterKeyStoredStatus: Equatable {
  case available(accessMode: KeychainAccessMode)
  case expired(accessMode: KeychainAccessMode)
  case notAvailable

  public init(keychainItemStatus: KeychainItemStatus, expired: Bool) {
    switch keychainItemStatus {
    case .found(accessible: let accessMode):
      switch (accessMode, expired) {
      case (.afterBiometricAuthentication, true):
        self = .expired(accessMode: .afterBiometricAuthentication)
      case (.afterBiometricAuthentication, false):
        self = .available(accessMode: .afterBiometricAuthentication)
      case (.whenDeviceUnlocked, true):
        self = .expired(accessMode: .whenDeviceUnlocked)
      case (.whenDeviceUnlocked, false):
        self = .available(accessMode: .whenDeviceUnlocked)
      }
    case .notFound:
      self = .notAvailable
    }
  }
}

public enum KeychainItemStatus: Equatable {
  case found(accessible: KeychainAccessMode)
  case notFound
}
