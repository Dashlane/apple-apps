import AuthenticatorKit
import DashTypes
import Foundation
import TOTPGenerator

@MainActor
class ScanQRCodeViewModel: ObservableObject {

  @Published
  var presentError = false

  let completion: (OTPInfo?) async -> Void
  let logger: Logger

  init(logger: Logger, completion: @escaping (OTPInfo?) async -> Void) {
    self.completion = completion
    self.logger = logger
  }

  func processQRCode(_ qrCode: String) {
    guard let info = try? OTPConfiguration(otpString: qrCode, supportDashlane2FA: true) else {
      presentError = true
      logger.error("Couldn't parse otp configuration from the qrcode")
      return
    }
    Task {
      await otpTokenDetected(token: OTPInfo(configuration: info))
    }
  }

  private func otpTokenDetected(token: OTPInfo) async {
    await completion(token)
  }
}
