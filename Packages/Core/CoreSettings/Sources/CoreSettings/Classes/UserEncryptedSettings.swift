import Combine
import DashTypes
import Foundation

public enum UserEncryptedSettingsKey: String, CaseIterable, LocalSettingsKey {
  case teamSpaces = "KW_USER_TEAM_SPACES"
  case premiumStatusData = "premiumStatusData"
  case receiptHash = "receiptHash"
  case autofillData = "autofillData"

  public var identifier: String {
    return rawValue
  }

  public var type: Any.Type {
    switch self {
    case .teamSpaces:
      return String.self
    case .premiumStatusData, .receiptHash, .autofillData:
      return Data.self
    }
  }

  public var isEncrypted: Bool {
    return true
  }
}

public typealias UserEncryptedSettings = KeyedSettings<UserEncryptedSettingsKey>
