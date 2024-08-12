import Combine
import CoreFeature
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import VaultKit

class SessionReporterService: DependenciesContainer {
  let activityReporter: ActivityReporterProtocol
  let deviceInformation: DeviceInformationReporting
  let loginMetricsReporter: LoginMetricsReporter

  private var subscriptions: Set<AnyCancellable> = []

  init(
    activityReporter: ActivityReporterProtocol,
    loginMetricsReporter: LoginMetricsReporter,
    deviceInformation: DeviceInformationReporting
  ) {
    self.activityReporter = activityReporter
    self.loginMetricsReporter = loginMetricsReporter
    self.deviceInformation = deviceInformation
  }

  func postLoadConfigure(
    using services: SessionServicesContainer, loadingContext: SessionLoadingContext
  ) {

    reportPerformanceMetrics(for: loadingContext)
    services.appServices.loginMetricsReporter.reset()
    deviceInformation.report()

    configureReportOnSync(using: services)
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

  fileprivate func configureReportOnSync(using services: SessionServicesContainer) {

    services.syncService.$syncStatus
      .throttle(for: .seconds(5), scheduler: DispatchQueue.backgroundReporter, latest: true)
      .filter { $0.isIdle }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.onSync(services: services)
      }.store(in: &subscriptions)
  }

  fileprivate func onSync(services: SessionServicesContainer) {
    reportGeneralStates(using: services)
    activityReporter.flush()
  }

  fileprivate func reportGeneralStates(using services: SessionServicesContainer) {

    let settings = services.spiegelLocalSettingsStore.keyed(by: ReporterSettingsKey.self)

    let lastReportDate: Date = settings[.lastStateReportDate] ?? .distantPast
    guard lastReportDate.hoursPassed > 24 else {
      return
    }
    settings[.lastStateReportDate] = Date()

    let vaultReportService = VaultReportService(
      identityDashboardService: services.identityDashboardService,
      userSettings: services.spiegelUserSettings,
      vaultItemsStore: services.vaultServicesSuit.vaultItemsStore,
      vaultCollectionsStore: services.vaultServicesSuit.vaultCollectionsStore,
      apiClient: services.userDeviceAPIClient.useractivity,
      userSpacesService: services.userSpacesService,
      activityReporter: services.activityReporter)
    vaultReportService.report()

    activityReporter.reportUserSettings(
      services.spiegelUserSettings,
      autofillService: services.autofillService,
      resetMPService: services.resetMasterPasswordService,
      lock: services.lockService)
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
