import CorePersonalData
import CoreSettings
import Foundation
import TOTPGenerator
import VaultKit

public struct OTPNotificationSender {
  let userSettings: UserSettings
  let localNotificationService: LocalNotificationService

  func send(for credential: Credential) {
    if #unavailable(iOS 18.0),
      let otpURL = credential.otpURL, let otpInfo = try? OTPConfiguration(otpURL: otpURL)
    {

      let code = TOTPGenerator.generate(
        with: otpInfo.type,
        for: Date(),
        digits: otpInfo.digits,
        algorithm: otpInfo.algorithm,
        secret: otpInfo.secret)
      let hasClipboardOverride: Bool? = userSettings[.clipboardOverrideEnabled]

      if hasClipboardOverride == true {
        PasteboardService(userSettings: userSettings).copy(code)
      }

      let otpNotification = OTPLocalNotification(
        pin: code, itemId: credential.id.rawValue,
        hasClipboardOverride: hasClipboardOverride ?? false,
        domain: credential.url?.displayDomain)
      localNotificationService.send(otpNotification)
    }
  }
}

extension SessionServicesContainer {
  var otpNotificaitonSender: OTPNotificationSender {
    OTPNotificationSender(
      userSettings: userSettings, localNotificationService: LocalNotificationService())
  }
}
