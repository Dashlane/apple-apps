import Foundation
import DashTypes
import NotificationCenter
import UIKit
import TOTPGenerator
import CoreNetworking
import SwiftTreats

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
        return TOTPGenerator.generate(with: info.type, for: Date(), digits: info.digits, algorithm: info.algorithm, secret: info.secret)
    }
    
    
}
