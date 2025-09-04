import CorePersonalData
import Foundation
import TOTPGenerator

extension Credential {
  public var otpConfiguration: OTPConfiguration? {
    guard let otpURL = otpURL else {
      return nil
    }
    return try? OTPConfiguration(otpURL: otpURL)
  }
}
