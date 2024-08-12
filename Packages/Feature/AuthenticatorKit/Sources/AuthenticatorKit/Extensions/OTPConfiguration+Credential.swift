import CorePersonalData
import Foundation
import TOTPGenerator

extension OTPInfo {
  public init?(credential: Credential, supportDashlane2FA: Bool, recoveryCodes: [String] = []) {
    guard let otpURL = credential.otpURL else { return nil }
    let subtitle =
      credential.displaySubtitle != credential.displayTitle ? credential.displaySubtitle : nil
    guard
      let config = try? OTPConfiguration(
        otpURL: otpURL,
        supportDashlane2FA: supportDashlane2FA,
        defaultTitle: credential.displayTitle,
        defaultLogin: subtitle,
        defaultIssuer: credential.url?.displayDomain)
    else {
      return nil
    }
    self.init(
      id: credential.id, configuration: config, isFavorite: credential.isFavorite,
      recoveryCodes: recoveryCodes)
  }
}
