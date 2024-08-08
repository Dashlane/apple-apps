import DashlaneAPI
import Foundation

public enum Dashlane2FAType: String, Identifiable, Hashable {
  public var id: String {
    return rawValue
  }
  case otp1
  case otp2
}

extension Authentication2FAStatusType {
  public var twoFAType: Dashlane2FAType? {
    switch self {
    case .totpLogin:
      return .otp2
    case .totpDeviceRegistration:
      return .otp1
    default:
      return nil
    }
  }
}
