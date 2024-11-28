import Combine
import CoreFeature
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import VaultKit

final class SessionReporterService: DependenciesContainer {
  let activityReporter: ActivityReporterProtocol
  let deviceInformation: DeviceInformationReporting
  let loginMetricsReporter: LoginMetricsReporter
  let syncService: SyncService
  let reportSettings: KeyedSettings<ReporterSettingsKey>
  let vaultReportService: VaultReportService
  let reportUserSettingsService: ReportUserSettingsService

  private var subscriptions: Set<AnyCancellable> = []

  init(
    activityReporter: ActivityReporterProtocol,
    deviceInformation: DeviceInformationReporting,
    loginMetricsReporter: LoginMetricsReporter,
    syncService: SyncService,
    settings: LocalSettingsStore,
    vaultReportService: VaultReportService,
    reportUserSettingsService: ReportUserSettingsService
  ) {
    self.activityReporter = activityReporter
    self.deviceInformation = deviceInformation
    self.loginMetricsReporter = loginMetricsReporter
    self.syncService = syncService
    self.reportSettings = settings.keyed(by: ReporterSettingsKey.self)
    self.vaultReportService = vaultReportService
    self.reportUserSettingsService = reportUserSettingsService
  }

  func postLoadReport(for loadingContext: SessionLoadingContext) {
    reportPerformanceMetrics(for: loadingContext)
    loginMetricsReporter.reset()
    deviceInformation.report()

  }

  func configureReportOnSync() {
    syncService.$syncStatus
      .throttle(for: .seconds(5), scheduler: DispatchQueue.backgroundReporter, latest: true)
      .filter { $0.isIdle }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.onSync()
      }.store(in: &subscriptions)
  }

  func unload(reason: SessionServicesUnloadReason) {
    if reason == .userLogsOut {
      deviceInformation.reportOnLogout()
    }
    activityReporter.flush()
  }

  private func reportPerformanceMetrics(for loadingContext: SessionLoadingContext) {
    if let performanceLogInfo = loginMetricsReporter.getPerformanceLogInfo(.login),
      let measureName = loadingContext.measureName
    {
      activityReporter.report(performanceLogInfo.performanceUserEvent(for: measureName))
      loginMetricsReporter.resetTimer(.login)
    }
  }
}

extension SessionReporterService {

  fileprivate func onSync() {
    reportGeneralStates()
    activityReporter.flush()
  }

  fileprivate func reportGeneralStates() {
    let lastReportDate: Date = reportSettings[.lastStateReportDate] ?? .distantPast
    guard lastReportDate.hoursPassed > 24 else {
      return
    }
    reportSettings[.lastStateReportDate] = Date()

    vaultReportService.report()
    reportUserSettingsService.report()
  }
}

extension DispatchQueue {

  fileprivate static let backgroundReporter = DispatchQueue(
    label: "com.dashlane.backgroundReporter", qos: .utility)
}

extension Date {
  fileprivate var hoursPassed: Int {
    return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
  }
}

extension SyncService.SyncStatus {
  fileprivate var isIdle: Bool {
    guard case .idle = self else {
      return false
    }
    return true
  }
}

extension SessionLoadingContext {
  fileprivate var measureName: Definition.MeasureName? {
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
