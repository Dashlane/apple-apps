import CoreTypes
import Foundation
import NotificationCenter
import SwiftTreats
import TOTPGenerator
import UIKit

@available(iOS, deprecated: 14.0)
class DashlaneTodayViewController: TodayViewController {
  override func viewDidLoad() {
    self.otpGenerationDelegate = self
    super.viewDidLoad()
  }
}

@available(iOS, deprecated: 14.0)
extension DashlaneTodayViewController: OTPGenerator {
  public func generate(with info: OTPConfiguration) -> String {
    return TOTPGenerator.generate(
      with: info.type, for: Date(), digits: info.digits, algorithm: info.algorithm,
      secret: info.secret)
  }

}
