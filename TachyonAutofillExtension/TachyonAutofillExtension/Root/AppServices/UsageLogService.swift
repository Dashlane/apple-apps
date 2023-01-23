import Foundation
import DashlaneReportKit
import CoreNetworking
import CoreSession
import UIKit
import DashTypes
import DashlaneCrypto
import CoreFeature
import SwiftTreats
import DashlaneAppKit
import LoginKit

protocol UsageLogServiceProtocol {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?)
}

extension UsageLogServiceProtocol {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        post(log, completion: completion)
    }
}

class UsageLogService: UsageLogServiceProtocol {
    
    private let engine: LogEngine
    private let loginUsageLogService: LoginUsageLogService
    private let linkedDomainsService: LinkedDomainService
    private let apiClient: DeprecatedCustomAPIClient

        private var performanceLogInfo: LoginPerformanceLogInfo?

    init(anonymousUserId: String,
         appSettings: AppSettings,
         legacyWebService: LegacyWebService,
         apiClient: DeprecatedCustomAPIClient,
         session: Session,
         loginUsageLogService: LoginUsageLogService,
         linkedDomainsService: LinkedDomainService,
         localKeyCryptoEngine: CryptoEngine) {

        self.linkedDomainsService = linkedDomainsService
        let workingDirectory = FileManager.default.temporaryDirectory
        let reportLogInfo = UsageLogInfo(
            userId: anonymousUserId,
            device: appSettings.anonymousDeviceId,
            session: Int(Date().timeIntervalSince1970),
            platform: DeviceHardware.name,
            version: Application.version(),
            osversion: System.version,
            usagePartnerId: ApplicationSecrets.Server.partnerId,
            sdkVersion: "",
            testRealUserId: session.login.isTest ? session.login.email : nil,
            sessionDirectory: workingDirectory)
        self.apiClient = apiClient
        engine = LogEngine(reportLogInfo: reportLogInfo,
                           uploadWebService: legacyWebService,
                           cryptoDelegate: localKeyCryptoEngine,
                           useLogTrigger: true)
        self.loginUsageLogService = loginUsageLogService
    }

    func reportSuccessAutofill(for domain: String?, visitedWebsite: String, withoutUserInteraction: Bool) {
        let credentialOrigin: UsageLogCode5Autofill.Credential_originType = {
            if !withoutUserInteraction {
                return .viewAllAccounts
            }
            if let domain = domain, domain != visitedWebsite, linkedDomainsService[domain]?.contains(visitedWebsite) ?? false {
                return .associatedWebsite
            }
            return .classic
        }()
        
        let logData = UsageLogCode5Autofill(information: "AUTHENTICATION",
                                            details: "",
                                            url: "",
                                            trigger: true,
                                            website: visitedWebsite,
                                            AUTHENTICATION: 2,
                                            credential_origin: credentialOrigin,
                                            vault_item_website: domain ?? "")
        self.engine.post(logData)
        self.engine.uploadLogs()
    }
    
    func reportOTPNotificationSent(for domain: String?) {
        guard let domain = domain else { return }
        let logData = UsageLogCode75GeneralActions(type: "otpNotification", action: "sent", website: domain)
        self.engine.post(logData)
        self.engine.uploadLogs()
    }
    
    func getPerformanceLogInfo() -> LoginPerformanceLogInfo? {
        if let performanceLogInfo = self.performanceLogInfo {
            return performanceLogInfo
        }
        self.performanceLogInfo = loginUsageLogService.performanceLogInfo(.login)
        return self.performanceLogInfo
    }
    
    func logLogin() {
        guard let performanceLogInfo = getPerformanceLogInfo(),
              case let .timeToLogin(authType) = performanceLogInfo.performanceLogType else { return }
        engine.reportClientPerf(action: "timeToLoadAutofill",
                                duration: performanceLogInfo.duration,
                                type: authType.logValue,
                                apiClient: apiClient) { _ in }
        loginUsageLogService.resetTimer(.login)
    }
    
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        engine.post(log, completion: completion)
    }
}

extension UsageLogService {
    private class FakeUsageLogService: UsageLogServiceProtocol {
        func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?) {}
    }

    static var fakeService: UsageLogServiceProtocol {
        return FakeUsageLogService()
    }
}

extension UsageLogService: ABTestingLogger {
    func log(_ test: ABTestProtocol) {
        let log = UsageLogCode132ABTest(experiment_id: type(of: test).technicalName,
                                        version_id: test.version,
                                        variant_id: test.rawVariant)
        post(log)
    }
}
