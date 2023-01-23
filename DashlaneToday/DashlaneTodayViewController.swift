import Foundation
import DashTypes
import NotificationCenter
import UIKit
import DashlaneReportKit
import TOTPGenerator
import CoreNetworking
import SwiftTreats

@available(iOS, deprecated: 14.0)
class DashlaneTodayViewController: TodayViewController {
    private var logEngine: LogEngine?
    
    override func viewDidLoad() {
        self.otpGenerationDelegate = self
        self.loggerDelegate = self
        super.viewDidLoad()
    }
    
    override func updateContext() {
        super.updateContext()
        configureReportCenter()
    }
    
    private func configureReportCenter() {
        guard let info = context.reportHeaderInfo else { return }
        let workingDirectory = FileManager.default.temporaryDirectory
        
        let reportLogInfo = DashlaneReportKit.UsageLogInfo(
            userId: info.userId,
            device: info.device,
            session: Int(Date().timeIntervalSince1970),
            platform: DeviceHardware.name,
            version: Application.version(),
            osversion: System.version,
            usagePartnerId: ApplicationSecrets.Server.partnerId,
            sdkVersion: "",
            testRealUserId: nil,
            sessionDirectory: workingDirectory)
        
        logEngine = LogEngine(reportLogInfo: reportLogInfo, uploadWebService: LegacyWebServiceImpl(serverConfiguration: .init(platform: .passwordManager)))
    }
    
}

@available(iOS, deprecated: 14.0)
extension DashlaneTodayViewController: TodayActionLogger {
    func logViewAppeared() {
        let subaction: UsageLogCode112CredentialTOTPActions.SubactionType = FileProtectionUtility.shared.lockState.isLocked() ? .locked : .unlocked
        let log = UsageLogCode112CredentialTOTPActions(type: .widget, subtype: .fromToday, action: .view, subaction: subaction)
        logEngine?.post(log)
        logEngine?.uploadLogs()
    }
    
    func logSelectedEntry(title: String) {
        let log = UsageLogCode112CredentialTOTPActions(type: .widget, subtype: .fromToday, action: .copy, website: title)
        logEngine?.post(log)
    }
    
    func sendLogs() {
        logEngine?.uploadLogs()
    }
}

@available(iOS, deprecated: 14.0)
extension DashlaneTodayViewController: OTPGenerator {
    public func generate(with info: OTPConfiguration) -> String {
        return TOTPGenerator.generate(with: info.type, for: Date(), digits: info.digits, algorithm: info.algorithm, secret: info.secret)
    }
    
    
}
