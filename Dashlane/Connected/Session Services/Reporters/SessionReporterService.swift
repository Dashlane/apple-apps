import Foundation
import DashlaneAppKit
import CoreUserTracking
import CoreFeature
import Combine
import LoginKit
import DashTypes

class SessionReporterService: DependenciesContainer {
    let activityReporter: ActivityReporterProtocol
    let deviceInformation: DeviceInformationReporting

        let legacyAggregated: AggregatedLogService
        let legacyUsage: UsageLogServiceProtocol

    private var subscriptions: Set<AnyCancellable> = []

    init(activityReporter: ActivityReporterProtocol,
         deviceInformation: DeviceInformationReporting,
         legacyAggregated: AggregatedLogService,
         legacyUsage: UsageLogServiceProtocol) {
        self.activityReporter = activityReporter
        self.deviceInformation = deviceInformation
        self.legacyAggregated = legacyAggregated
        self.legacyUsage = legacyUsage
    }

        func postLoadConfigure(using services: SessionServicesContainer, loadingContext: SessionLoadingContext) {

        reportPerformanceMetrics(for: loadingContext)
        legacyUsage.sendCachedLogs()
        if loadingContext == .accountCreation {
            legacyUsage.sendAccountCreationUsageLogs()
        }
        services.appServices.loginUsageLogService.reset()
        deviceInformation.report()
        performDeduplicationAudit(using: services)

        configureReportOnSync(using: services)
        configureReportFlipsStatus(using: services.featureService)
    }

    func unload(reason: SessionServicesUnloadReason) {
        legacyUsage.unload(loginStartDate: legacyAggregated.startDate) {}
        legacyAggregated.unload()
        if reason == .userLogsOut {
            deviceInformation.reportOnLogout()
        }
        activityReporter.flush()
    }

    private func reportPerformanceMetrics(for loadingContext: SessionLoadingContext) {
        if let performanceLogInfo = legacyUsage.getPerformanceLogInfo(),
           let measureName = loadingContext.measureName {
            activityReporter.report(performanceLogInfo.performanceUserEvent(for: measureName))
        }
        legacyUsage.sendLoginUsageLogs(loadingContext: loadingContext)
    }
}

private extension SessionReporterService {

    func performDeduplicationAudit(using services: SessionServicesContainer) {
        if services.featureService.isEnabled(.deduplicationAudit) {
            DeduplicationAudit(credentials: services.vaultItemsService.credentials,
                               linkedDomainService: services.appServices.linkedDomainService,
                               usageLogService: legacyUsage,
                               userSettings: services.spiegelUserSettings)
                .performAuditIfNeeded()
        }
    }

    func configureReportFlipsStatus(using featureService: FeatureService) {
        featureService.featureFlipUsageLogger.logsPublisher().sink { [weak self] log in
            self?.legacyUsage.post(log)
        }.store(in: &subscriptions)
    }

    func configureReportOnSync(using services: SessionServicesContainer) {

        services.syncService.$syncStatus
            .throttle(for: .seconds(5), scheduler: DispatchQueue.backgroudReporter, latest: true)
            .filter { $0.isIdle }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onSync(services: services)
            }.store(in: &subscriptions)
    }

    func onSync(services: SessionServicesContainer) {
        reportGeneralStates(using: services)
        activityReporter.flush()
    }

    func reportGeneralStates(using services: SessionServicesContainer) {

        let settings = services.spiegelLocalSettingsStore.keyed(by: ReporterSettingsKey.self)

        let lastReportDate: Date = settings[.lastStateReportDate] ?? .distantPast
        guard lastReportDate.hoursPassed > 24 else {
            return
        }
        settings[.lastStateReportDate] = Date()

        let vaultReportService = VaultReportService(identityDashboardService: services.identityDashboardService,
                                                    userSettings: services.spiegelUserSettings,
                                                    vaultItemsService: services.vaultItemsService,
                                                    teamSpacesService: services.teamSpacesService,
                                                    activityReporter: services.activityReporter)
        vaultReportService.report()

        activityReporter.reportUserSettings(services.spiegelUserSettings,
                                  autofillService: services.autofillService,
                                  resetMPService: services.resetMasterPasswordService,
                                  lock: services.lockService)
    }
}

private extension DispatchQueue {

    static let backgroudReporter = DispatchQueue(label: "com.dashlane.backgroundReporter", qos: .utility)
}

private extension Date {
    var hoursPassed: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
    }
}

private extension SyncService.SyncStatus {
    var isIdle: Bool {
        guard case .idle = self else {
            return false
        }
        return true
    }
}

private extension SessionLoadingContext {
    var measureName: Definition.MeasureName? {
        switch self {
        case .localLogin:
            return .timeToLoadLocal
        case .remoteLogin:
            return .timeToLoadRemote
        default:
            return nil
        }
    }
}
