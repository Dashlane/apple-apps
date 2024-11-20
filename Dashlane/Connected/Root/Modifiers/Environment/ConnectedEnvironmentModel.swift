import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import MacrosKit
import VaultKit

class ConnectedEnvironmentModel: SessionServicesInjecting, ObservableObject {

  @Published
  var enabledFeaturesAtLogin: Set<ControlledFeature> = []
  @Published
  var capabilities: [CapabilityKey: CapabilityStatus] = [:]
  @Published
  var richIconsEnabled: Bool = true
  @Published
  var spacesConfiguration: UserSpacesService.SpacesConfiguration

  var reportAction: ReportAction {
    return .init(reporter: activityReporter)
  }

  var copyAction: (String) -> Void {
    return pasteboardService.copy
  }

  private let featureService: any FeatureServiceProtocol
  private let capabilitiesService: any CapabilityServiceProtocol
  private let activityReporter: any ActivityReporterProtocol
  private let pasteboardService: any PasteboardServiceProtocol

  init(
    featureService: FeatureServiceProtocol,
    userSpaceService: UserSpacesService,
    capabilitiesService: CapabilityServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    syncedSettings: SyncedSettingsService,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.featureService = featureService
    self.capabilitiesService = capabilitiesService
    self.activityReporter = activityReporter
    self.pasteboardService = pasteboardService

    enabledFeaturesAtLogin = featureService.enabledFeatures()

    capabilities = capabilitiesService.allStatus()
    spacesConfiguration = userSpaceService.configuration

    capabilitiesService.allStatusPublisher()
      .receive(on: DispatchQueue.main)
      .removeDuplicates(by: { [weak self] _, after in
        after == self?.capabilities
      })
      .assign(to: &$capabilities)
    userSpaceService.$configuration
      .receive(on: DispatchQueue.main)
      .removeDuplicates(by: { [weak self] _, after in
        after == self?.spacesConfiguration
      })
      .assign(to: &$spacesConfiguration)

    richIconsEnabled =
      if userSpaceService.configuration.currentTeam?.isRichIconsDisabled == true {
        false
      } else {
        syncedSettings[\.richIcons]
      }

    syncedSettings.changes(of: \.richIcons)
      .combineLatest(userSpaceService.$configuration)
      .map { richIconsEnabledInSetting, configuration in
        if configuration.currentTeam?.isRichIconsDisabled == true {
          return false
        } else {
          return richIconsEnabledInSetting
        }
      }
      .removeDuplicates(by: { [weak self] _, after in
        after == self?.richIconsEnabled
      })
      .receive(on: DispatchQueue.main)
      .assign(to: &$richIconsEnabled)
  }
}
