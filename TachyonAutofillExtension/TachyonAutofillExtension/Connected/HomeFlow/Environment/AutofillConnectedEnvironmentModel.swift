import CoreFeature
import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import MacrosKit

class AutofillConnectedEnvironmentModel: SessionServicesInjecting, ObservableObject {
  let featureService: any FeatureServiceProtocol
  let capabilitiesService: any CapabilityServiceProtocol
  let activityReportProtocol: any ActivityReporterProtocol

  @Published
  var enabledFeaturesAtLogin: Set<ControlledFeature> = []
  @Published
  var capabilities: [CapabilityKey: CapabilityStatus] = [:]
  @Published
  var richIconsEnabled: Bool = true

  var reportAction: ReportAction {
    return .init(reporter: activityReportProtocol)
  }

  init(
    featureService: FeatureServiceProtocol,
    capabilitiesService: CapabilityServiceProtocol,
    activityReportProtocol: ActivityReporterProtocol,
    syncedSettings: SyncedSettingsService
  ) {
    self.featureService = featureService
    self.capabilitiesService = capabilitiesService
    self.activityReportProtocol = activityReportProtocol

    enabledFeaturesAtLogin = featureService.enabledFeatures()

    capabilities = capabilitiesService.allStatus()
    capabilitiesService.allStatusPublisher()
      .receive(on: DispatchQueue.main)
      .assign(to: &$capabilities)

    richIconsEnabled = syncedSettings[\.richIcons]
    syncedSettings.changes(of: \.richIcons)
      .receive(on: DispatchQueue.main)
      .assign(to: &$richIconsEnabled)
  }
}
