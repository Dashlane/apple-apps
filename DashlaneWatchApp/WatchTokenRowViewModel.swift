import Foundation
import TOTPGenerator

class WatchTokenRowViewModel: ObservableObject {
  @Published var code: String = ""

  let issuer: String
  let otpConfiguration: OTPConfiguration?

  init(token: WatchApplicationContext.Token) {
    self.issuer = token.title
    self.otpConfiguration = try? OTPConfiguration(otpURL: token.url)

    if let otpConfiguration, case .hotp(let counter) = otpConfiguration.type {
      self.code = TOTPGenerator.generate(
        with: otpConfiguration.type,
        for: Date(),
        digits: otpConfiguration.digits,
        algorithm: otpConfiguration.algorithm,
        secret: otpConfiguration.secret,
        currentCounter: counter
      )
    }
  }
}
