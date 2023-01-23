import Foundation
import DashlaneReportKit
import CoreNetworking
import CoreSession
import DashTypes
import Combine
import SwiftTreats
import DashlaneAppKit
import LoginKit
import CoreSettings
import UIKit
import PremiumKit
import CorePersonalData

protocol UsageLogServiceProtocol: PremiumLogService {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?)
    func unload(loginStartDate: Date, _ completion: @escaping VoidCompletionBlock)
    func uploadAggregatedLogs(_ aggregatedLogs: [String: Encodable])
    func uploadLogs()
    func logDidUnlock()
    func sendLoginUsageLogs(loadingContext: SessionLoadingContext)
    func sendCachedLogs()
    func sendAccountCreationUsageLogs()
    func getPerformanceLogInfo() -> LoginPerformanceLogInfo?

    var addItemLogger: AddItemUsageLogger { get }
    var teamSpaceLogger: TeamSpacesUsageLogger { get }
    var userActionsAggregatedLogs: [AggregatedLogService.ServerKey: String] { get set }
}

extension UsageLogServiceProtocol {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        self.post(log, completion: completion)
    }
}

class UsageLogService: UsageLogServiceProtocol {
    let logDirectory: URL
    let login: Login
    let cryptoService: CryptoEngine
    let logger: Logger
    let loginUsageLogService: LoginUsageLogServiceProtocol
    let anonymousUserId: String?
    let anonymousDeviceId: String
    let apiClient: DeprecatedCustomAPIClient
    private var engine: LogEngine

    private let logQueue: DispatchQueue

    lazy var account: AccountLogSection = {
        return AccountLogSection(logEngine: self.engine)
    }()

    lazy var personalData: PersonalDataLogSection = {
        return PersonalDataLogSection(logEngine: self.engine)
    }()

    lazy var sidebar: SidebarLogSection = {
        return SidebarLogSection(logEngine: self.engine)
    }()

    var addItemLogger: AddItemUsageLogger {
        AddItemUsageLogger(usageLogService: self)
    }

    var teamSpaceLogger: TeamSpacesUsageLogger {
        TeamSpacesUsageLogger(usageLogService: self)
    }

    var userActionsAggregatedLogs: [AggregatedLogService.ServerKey: String] = [:]

        private var performanceLogInfo: LoginPerformanceLogInfo?

    private var cancellables = Set<AnyCancellable>()

    init(logDirectory: URL,
         cryptoService: CryptoEngine,
         nonAuthenticatedLegacyWebService: LegacyWebService,
         apiClient: DeprecatedCustomAPIClient,

         syncedSettings: SyncedSettingsService,
         loginUsageLogService: LoginUsageLogServiceProtocol,
         userSettings: UserSettings,
         anonymousDeviceId: String,
         login: Login,
         logger: Logger) {

        self.logDirectory = logDirectory
        self.loginUsageLogService = loginUsageLogService
        self.cryptoService = cryptoService
        self.anonymousUserId = syncedSettings[\.anonymousUserId]
        self.anonymousDeviceId = anonymousDeviceId
        self.login = login
        self.logger = logger
        let reportLogInfo = UsageLogInfo(
            userId: self.anonymousUserId ?? "",
            device: anonymousDeviceId,
            session: Int(Date().timeIntervalSince1970),
            platform: System.platform,
            version: Application.version(),
            osversion: System.version,
            usagePartnerId: ApplicationSecrets.Server.partnerId,
            sdkVersion: "",
            testRealUserId: self.login.isTest ? self.login.email : nil,
            sessionDirectory: self.logDirectory)
        self.engine = LogEngine(reportLogInfo: reportLogInfo,
                                uploadWebService: nonAuthenticatedLegacyWebService,
                                cryptoDelegate: self.cryptoService,
                                useLogTrigger: true,
                                localLogger: logger,
                                journalPath: nil)
        self.apiClient = apiClient
        self.logQueue = .init(label: "Uploading logs queue", qos: .utility, attributes: .concurrent)

        NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification).sink { [weak self] _ in
                        self?.engine.uploadLogs()
        }.store(in: &cancellables)

    }

    func unload(loginStartDate: Date, _ completion: @escaping VoidCompletionBlock) {
        logQueue.async {
            self.sendLogoutUsageLogs(loginStartDate: loginStartDate)
            self.engine.uploadLogs { _ in
                completion()
            }
        }
    }

    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        aggregateIfNeeded(log)
        engine.post(log, completion: completion)
    }

    func uploadAggregatedLogs(_ aggregatedLogs: [String: Encodable]) {
        logQueue.async {
            self.engine.upload(aggregatedLogs: aggregatedLogs)
        }
    }

    func uploadLogs() {
        engine.uploadLogs()
    }

    func sendLoginUsageLogs(loadingContext: SessionLoadingContext) {
        if loginUsageLogService.hasRegisteredNewDevice {
            post(loginUsageLogService.newDeviceLog(anonymousComputerId: anonymousDeviceId,
                                                   fromAccountCreation: loadingContext == .accountCreation))
        }

                logDidLogin()
    }

    func getPerformanceLogInfo() -> LoginPerformanceLogInfo? {
        if let performanceLogInfo = self.performanceLogInfo {
            return performanceLogInfo
        }
        self.performanceLogInfo = loginUsageLogService.performanceLogInfo(.login)
        return self.performanceLogInfo
    }

    private func logDidLogin() {
        guard let performanceLogInfo = getPerformanceLogInfo(),
              case let .timeToLogin(authType) = performanceLogInfo.performanceLogType else { return }
        let action = loginUsageLogService.hasRegisteredNewDevice ? "timeToLoadRemote" : "timeToLoadLocal"
        engine.reportClientPerf(action: action,
                                duration: performanceLogInfo.duration,
                                type: authType.logValue,
                                apiClient: apiClient) { _ in }

        guard let log = loginUsageLogService.loginUsageLog() else { return }
        post(log)

        loginUsageLogService.resetTimer(.login)
    }

        func sendCachedLogs() {
        loginUsageLogService.getAndClearCachedLogs().forEach { self.post($0) }
    }

    func sendLogoutUsageLogs(loginStartDate: Date) {
        let duration = Date().timeIntervalSince(loginStartDate)
        let log = UsageLogCode3UserLogout(sender: .fromMobile,
                                          duration: Int(duration))
        post(log)
    }

    func sendAccountCreationUsageLogs() {
        let log = loginUsageLogService.accountCreationUsageLogs(anonymousDeviceId: anonymousDeviceId)
        engine.uploadAccountCreation(log: log, osformat: System.country)
    }

        func logDidUnlock() {
        guard let performanceLogInfo = getPerformanceLogInfo(),
              case let .timeToLogin(authType) = performanceLogInfo.performanceLogType else { return }
        engine.reportClientPerf(action: "timeToUnlock",
                                duration: performanceLogInfo.duration,
                                type: authType.logValue,
                                apiClient: apiClient) { _ in }
        loginUsageLogService.resetTimer(.login)
    }
}

extension UsageLogService {
    private class FakeUsageLogService: UsageLogServiceProtocol {
        func getPerformanceLogInfo() -> LoginPerformanceLogInfo? { nil }
        func sendLoginUsageLogs(loadingContext: SessionLoadingContext) {}
        func sendCachedLogs() {}
        func sendAccountCreationUsageLogs() {}

        func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?) {}
        func unload(loginStartDate: Date, _ completion: @escaping VoidCompletionBlock) {}
        func uploadAggregatedLogs(_ aggregatedLogs: [String: Encodable]) {}
        func logDidUnlock() {}
        func uploadLogs() {}

        var addItemLogger: AddItemUsageLogger {
            AddItemUsageLogger(usageLogService: self)
        }

        var teamSpaceLogger: TeamSpacesUsageLogger {
            TeamSpacesUsageLogger(usageLogService: self)
        }
        var userActionsAggregatedLogs: [AggregatedLogService.ServerKey: String] = [:]
    }

    static var fakeService: UsageLogServiceProtocol {
        return FakeUsageLogService()
    }
}

extension FileManager {
    var usageLogsJournalUrl: URL? {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("usageLogs.journal")
    }
}
